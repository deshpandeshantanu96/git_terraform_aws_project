import boto3
import time
import logging
from typing import Optional

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class DNSManager:
    def __init__(self):
        try:
            self.route53 = boto3.client('route53')
            self.elbv2 = boto3.client('elbv2')
            self.ec2 = boto3.client('ec2')
        except Exception as e:
            logger.error(f"Failed to initialize AWS clients: {e}")
            raise

    def create_hosted_zone(self, domain_name: str, vpc_id: str) -> str:
        """Create or get existing private hosted zone"""
        try:
            if not domain_name.endswith('.'):
                domain_name += '.'

            # Verify VPC exists
            self._validate_vpc(vpc_id)

            response = self.route53.create_hosted_zone(
                Name=domain_name,
                HostedZoneConfig={
                    'Comment': 'Private DNS Zone for internal LB',
                    'PrivateZone': True
                },
                VPC={
                    'VPCRegion': 'us-east-1',
                    'VPCId': vpc_id
                },
                CallerReference=str(time.time())
            )
            logger.info(f"Created Hosted Zone: {response['HostedZone']['Id']}")
            return response['HostedZone']['Id']
        except self.route53.exceptions.ConflictingDomainExists:
            logger.warning(f"Hosted zone for {domain_name} already exists")
            return self._get_existing_zone_id(domain_name)
        except Exception as e:
            logger.error(f"Failed to create hosted zone: {e}")
            raise

    def _validate_vpc(self, vpc_id: str) -> None:
        """Verify VPC exists and is in correct region"""
        try:
            vpc = self.ec2.describe_vpcs(VpcIds=[vpc_id])
            if vpc['Vpcs'][0]['Region'] != 'us-east-1':
                raise ValueError(f"VPC {vpc_id} is not in us-east-1 region")
        except Exception as e:
            logger.error(f"VPC validation failed: {e}")
            raise

    def _get_existing_zone_id(self, domain_name: str) -> str:
        """Get ID of existing private hosted zone"""
        zones = self.route53.list_hosted_zones_by_name(DNSName=domain_name)
        for zone in zones['HostedZones']:
            if zone['Name'] == domain_name and zone['Config']['PrivateZone']:
                return zone['Id']
        raise ValueError(f"No existing private hosted zone found for {domain_name}")

    def find_internal_load_balancer(self, name_pattern: str = None) -> dict:
        """Find internal load balancer by name pattern or return first found"""
        try:
            paginator = self.elbv2.get_paginator('describe_load_balancers')
            for page in paginator.paginate():
                for lb in page['LoadBalancers']:
                    if lb['Scheme'] == 'internal':  # Key filter for internal LBs
                        if not name_pattern or name_pattern.lower() in lb['LoadBalancerName'].lower():
                            return lb
            raise ValueError("No internal load balancers found")
        except Exception as e:
            logger.error(f"Failed to find internal load balancer: {e}")
            raise

    def get_lb_dns_name(self, name_pattern: str = None) -> str:
        """Get DNS name of internal load balancer"""
        lb = self.find_internal_load_balancer(name_pattern)
        logger.info(f"Using internal LB: {lb['LoadBalancerName']}")
        return lb['DNSName']

    def create_dns_record(self, hosted_zone_id: str, domain_name: str, target_dns: str) -> dict:
        """Create or update DNS record"""
        try:
            if not domain_name.endswith('.'):
                domain_name += '.'

            response = self.route53.change_resource_record_sets(
                HostedZoneId=hosted_zone_id,
                ChangeBatch={
                    'Changes': [{
                        'Action': 'UPSERT',
                        'ResourceRecordSet': {
                            'Name': domain_name,
                            'Type': 'CNAME',
                            'TTL': 60,
                            'ResourceRecords': [{'Value': target_dns}]
                        }
                    }]
                }
            )
            logger.info(f"DNS record created/updated for {domain_name}")
            return response
        except Exception as e:
            logger.error(f"Failed to create DNS record: {e}")
            raise

def main():
    try:
        manager = DNSManager()
        
        # Configuration
        domain_name = "service.domain.internal"
        vpc_id = "vpc-07281342a2b001221"
        lb_name_pattern = "app"  # Pattern to match internal LB name
        
        # Step 1: Create or get hosted zone
        hosted_zone_id = manager.create_hosted_zone("dns_zone.internal", vpc_id)
        
        # Step 2: Find internal LB by name pattern
        lb_dns_name = manager.get_lb_dns_name(lb_name_pattern)
        
        # Step 3: Create DNS record
        manager.create_dns_record(hosted_zone_id, domain_name, lb_dns_name)
        
        logger.info("DNS setup completed successfully")
        return 0
    except Exception as e:
        logger.error(f"DNS setup failed: {e}")
        return 1

if __name__ == "__main__":
    exit(main())