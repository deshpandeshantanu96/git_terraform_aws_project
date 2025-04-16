import boto3
import time
import logging

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class DNSManager:
    def __init__(self):
        try:
            # Initialize AWS clients
            self.route53 = boto3.client('route53')
            self.elbv2 = boto3.client('elbv2')
            self.ec2 = boto3.client('ec2')
            self.region = boto3.session.Session().region_name
        except Exception as e:
            logger.error(f"Failed to initialize AWS clients: {e}")
            raise

    def create_hosted_zone(self, domain_name: str, vpc_id: str) -> str:
        """Create a private hosted zone"""
        try:
            if not domain_name.endswith('.'):
                domain_name += '.'

            # Create the hosted zone in Route 53
            response = self.route53.create_hosted_zone(
                Name=domain_name,
                HostedZoneConfig={
                    'Comment': 'Private DNS Zone for internal LB',
                    'PrivateZone': True  # This makes it a private hosted zone
                },
                VPC={
                    'VPCRegion': self.region,
                    'VPCId': vpc_id
                },
                CallerReference=str(time.time())  # Unique reference
            )
            logger.info(f"Created Hosted Zone: {response['HostedZone']['Id']}")
            return response['HostedZone']['Id']
        except self.route53.exceptions.ConflictingDomainExists:
            logger.warning(f"Hosted zone for {domain_name} already exists")
            return self._get_existing_zone_id(domain_name)
        except Exception as e:
            logger.error(f"Failed to create hosted zone: {e}")
            raise

    def _get_existing_zone_id(self, domain_name: str) -> str:
        """Get ID of existing private hosted zone"""
        try:
            paginator = self.route53.get_paginator('list_hosted_zones_by_name')
            for page in paginator.paginate(DNSName=domain_name):
                for zone in page['HostedZones']:
                    if zone['Name'] == domain_name and zone['Config']['PrivateZone']:
                        return zone['Id']
            raise ValueError(f"No existing private hosted zone found for {domain_name}")
        except Exception as e:
            logger.error(f"Failed to get existing zone ID: {e}")
            raise

    def find_internal_load_balancer(self, lb_name_pattern: Optional[str] = None) -> dict:
        """Find internal load balancer by name pattern"""
        try:
            paginator = self.elbv2.get_paginator('describe_load_balancers')
            for page in paginator.paginate():
                for lb in page['LoadBalancers']:
                    if lb['Scheme'] == 'internal':  # Key filter for internal LBs
                        if lb_name_pattern and lb_name_pattern.lower() not in lb['LoadBalancerName'].lower():
                            continue
                        logger.info(f"Found internal LB: {lb['LoadBalancerName']} (DNS: {lb['DNSName']})")
                        return lb
            raise ValueError("No internal load balancers found matching criteria")
        except Exception as e:
            logger.error(f"Failed to find internal load balancer: {e}")
            raise

    def create_dns_record(self, hosted_zone_id: str, domain_name: str, target_dns: str) -> dict:
        """Create or update DNS record"""
        try:
            if not domain_name.endswith('.'):
                domain_name += '.'

            # Create CNAME record pointing to the internal load balancer
            response = self.route53.change_resource_record_sets(
                HostedZoneId=hosted_zone_id,
                ChangeBatch={
                    'Changes': [{
                        'Action': 'UPSERT',  # Use UPSERT to create or update the record
                        'ResourceRecordSet': {
                            'Name': domain_name,
                            'Type': 'CNAME',  # CNAME to point to LB DNS
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
        # Initialize DNSManager
        manager = DNSManager()
        
        # Configuration
        domain_name = "service.domain.internal"
        vpc_id = "vpc-07281342a2b001221"  # Your VPC ID
        lb_name_pattern = "app"  # Pattern to match internal LB name
        
        logger.info(f"Starting DNS setup in region {manager.region}")
        
        # Step 1: Create or get hosted zone
        hosted_zone_id = manager.create_hosted_zone("dns_zone.internal", vpc_id)
        
        # Step 2: Find internal LB by name pattern
        lb_dns_name = manager.find_internal_load_balancer(lb_name_pattern)['DNSName']
        
        # Step 3: Create DNS record for internal LB
        manager.create_dns_record(hosted_zone_id, domain_name, lb_dns_name)
        
        logger.info("DNS setup completed successfully")
        return 0
    except Exception as e:
        logger.error(f"DNS setup failed: {e}")
        return 1

if __name__ == "__main__":
    exit(main())
