import boto3

# Initialize boto3 clients for Route 53 and ELB
route53_client = boto3.client('route53')
elb_client = boto3.client('elbv2')

# Step 1: Create a Private Hosted Zone
def create_hosted_zone(domain_name, vpc_id):
    response = route53_client.create_hosted_zone(
        Name=domain_name,
        CallerReference=str(hash(domain_name)),
        HostedZoneConfig={
            'Comment': 'Private DNS Zone for internal LB',
            'PrivateZone': True  # Private DNS zone
        },
        VPC={
            'VPCId': vpc_id
        }
    )
    print(f"Created Hosted Zone: {response['HostedZone']['Id']}")
    return response['HostedZone']['Id']

# Step 2: Get the Internal Load Balancer's DNS Name
def get_internal_lb_dns(lb_name):
    lb_details = elb_client.describe_load_balancers(
        Names=[lb_name]
    )
    lb_dns_name = lb_details['LoadBalancers'][0]['DNSName']
    return lb_dns_name

# Step 3: Create the DNS record to link the domain to the LB DNS Name
def create_record_set(hosted_zone_id, domain_name, lb_dns_name):
    record_set = {
        'Name': domain_name,
        'Type': 'CNAME',  # CNAME to point to the internal LB
        'TTL': 60,
        'ResourceRecords': [lb_dns_name]
    }

    response = route53_client.change_resource_record_sets(
        HostedZoneId=hosted_zone_id,
        ChangeBatch={
            'Changes': [{
                'Action': 'CREATE',
                'ResourceRecordSet': record_set
            }]
        }
    )
    print(f"Created DNS Record: {response}")

# Main Execution
domain_name = "service.test.internal"  # The domain name to be used
load_balancer_name = "my-internal-lb"  # Internal LB name
vpc_id = "vpc-xxxxxx"  # Your VPC ID

# Step 1: Create Hosted Zone
hosted_zone_id = create_hosted_zone("example.internal", vpc_id)

# Step 2: Get the DNS Name of the Internal LB
lb_dns_name = get_internal_lb_dns(load_balancer_name)

# Step 3: Create the CNAME record in the DNS Zone
create_record_set(hosted_zone_id, domain_name, lb_dns_name)
