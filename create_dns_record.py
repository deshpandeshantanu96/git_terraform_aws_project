import boto3
import time
import logging

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize boto3 clients with error handling
try:
    route53_client = boto3.client('route53')
    elb_client = boto3.client('elbv2')
except Exception as e:
    logger.error(f"Failed to initialize AWS clients: {e}")
    raise

def create_hosted_zone(domain_name, vpc_id):
    """Create a private hosted zone in Route 53"""
    try:
        # Ensure domain name ends with a dot
        if not domain_name.endswith('.'):
            domain_name += '.'
            
        response = route53_client.create_hosted_zone(
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
    except route53_client.exceptions.ConflictingDomainExists as e:
        logger.warning(f"Hosted zone already exists: {e}")
        # Try to get existing zone ID
        zones = route53_client.list_hosted_zones_by_name(DNSName=domain_name)
        for zone in zones['HostedZones']:
            if zone['Name'] == domain_name and zone['Config']['PrivateZone']:
                return zone['Id']
        raise
    except Exception as e:
        logger.error(f"Failed to create hosted zone: {e}")
        raise

def get_internal_lb_dns(lb_name):
    """Get DNS name of internal load balancer"""
    try:
        response = elb_client.describe_load_balancers(
            Names=[lb_name]
        )
        return response['LoadBalancers'][0]['DNSName']
    except elb_client.exceptions.LoadBalancerNotFoundException:
        logger.error(f"Load balancer {lb_name} not found")
        # List available LBs for debugging
        all_lbs = elb_client.describe_load_balancers()
        available = [lb['LoadBalancerName'] for lb in all_lbs['LoadBalancers']]
        logger.info(f"Available load balancers: {available}")
        raise
    except Exception as e:
        logger.error(f"Failed to get LB DNS name: {e}")
        raise

def create_record_set(hosted_zone_id, domain_name, lb_dns_name):
    """Create CNAME record in Route 53"""
    try:
        # Ensure domain name ends with a dot
        if not domain_name.endswith('.'):
            domain_name += '.'
            
        response = route53_client.change_resource_record_sets(
            HostedZoneId=hosted_zone_id,
            ChangeBatch={
                'Changes': [{
                    'Action': 'UPSERT',  # Use UPSERT instead of CREATE to avoid errors
                    'ResourceRecordSet': {
                        'Name': domain_name,
                        'Type': 'CNAME',
                        'TTL': 60,
                        'ResourceRecords': [{'Value': lb_dns_name}]
                    }
                }]
            }
        )
        logger.info(f"Created/updated DNS record: {response}")
        return response
    except Exception as e:
        logger.error(f"Failed to create record set: {e}")
        raise

def main():
    # Configuration
    domain_name = "service.domain.internal"  # The domain name to be used
    load_balancer_name = "app-lb-1"         # Internal LB name
    vpc_id = "vpc-07281342a2b001221"        # Your VPC ID
    
    try:
        # Step 1: Create or get existing hosted zone
        hosted_zone_id = create_hosted_zone("dns_zone.internal", vpc_id)
        
        # Step 2: Get the DNS Name of the Internal LB
        lb_dns_name = get_internal_lb_dns(load_balancer_name)
        
        # Step 3: Create the CNAME record in the DNS Zone
        create_record_set(hosted_zone_id, domain_name, lb_dns_name)
        
        logger.info("DNS setup completed successfully")
    except Exception as e:
        logger.error(f"DNS setup failed: {e}")
        return 1
    
    return 0

if __name__ == "__main__":
    exit(main())