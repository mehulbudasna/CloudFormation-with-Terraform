resource "aws_cloudformation_stack" "network" {
  name = "networking-stack"

  parameters = {
      VPCCidr = "10.0.0.0/16"
      CidrBlock = "10.0.0.0/24"
      Myip = "103.156.142.114/32"
  }

  template_body = <<STACK
AWSTemplateFormatVersion: 2010-09-09
Parameters:
  InstanceTypeParameter:
    Type: String
    Default: t3.micro
    Description: Enter instance size. Default is t3.micro.
  AMI:
    Type: String
    Default: ami-06bb3ee01d992f30d
    Description: The ubuntu AMI to use.
  Key:
    Type: String
    Default: flex
    Description: The key used to access the instance.
  VPCCidr:
    Type: String
    Default: 10.0.0.0/16
    Description: Enter the CIDR block for the VPC. Default is 10.0.0.0/16.
  CidrBlock:
    Type: String
    Default: 10.0.0.0/24
    Description: Enter the CIDR block for the VPC. Default is 10.0.0.0/24.
  Myip:
    Type: String
    Default: 103.156.142.114/32
    Description: Enter the IP address which you want to allow in SG . Default is 103.156.142.114/32.
Resources:
  VPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: !Ref VPCCidr
      EnableDnsSupport: true
      EnableDnsHostnames: true
      InstanceTenancy: default
      Tags:
        - Key: Name
          Value: ubuntu Target VPC
  InternetGateway:
    Type: AWS::EC2::InternetGateway
  VPCGatewayAttachment:
    Type: AWS::EC2::VPCGatewayAttachment
    Properties:
      VpcId: !Ref VPC
      InternetGatewayId: !Ref InternetGateway
  SubnetA:
    Type: AWS::EC2::Subnet
    Properties:
      AvailabilityZone: us-west-1b
      VpcId: !Ref VPC
      CidrBlock: !Ref CidrBlock
      MapPublicIpOnLaunch: true
  RouteTable:
    Type: AWS::EC2::RouteTable
    Properties:
      VpcId: !Ref VPC
  InternetRoute:
    Type: AWS::EC2::Route
    DependsOn: InternetGateway
    Properties:
      DestinationCidrBlock: 0.0.0.0/0
      GatewayId: !Ref InternetGateway
      RouteTableId: !Ref RouteTable
  SubnetARouteTableAssociation:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      RouteTableId: !Ref RouteTable
      SubnetId: !Ref SubnetA
  InstanceSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupName: "Octopus Target Group"
      GroupDescription: "Tentacle traffic in from hosted static ips, and RDP in from a personal workstation"
      VpcId: !Ref VPC
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: '22'
          ToPort: '22'
          CidrIp:  !Ref Myip
      SecurityGroupEgress:
        - IpProtocol: -1
          CidrIp: 0.0.0.0/0
  ElasticIP:
    Type: AWS::EC2::EIP
    Properties:
      Domain: vpc
      InstanceId: !Ref ubuntu
  ubuntu:
    Type: 'AWS::EC2::Instance'
    Properties:
      ImageId: !Ref AMI
      InstanceType:
        Ref: InstanceTypeParameter
      KeyName: !Ref Key
      SubnetId: !Ref SubnetA
      SecurityGroupIds:
        - Ref: InstanceSecurityGroup
      BlockDeviceMappings:
        - DeviceName: /dev/sda1
          Ebs:
            VolumeSize: 250
      UserData:
        Fn::Base64: !Sub |
          <powershell>
          Write-Host "Hello World!"
          </powershell>
      Tags:
        -
          Key: Appplication
          Value:  ubuntu Server
        -
          Key: Domain
          Value: None
        -
          Key: Environment
          Value: Test
        -
          Key: Name
          Value:  ubuntu Server Worker
        -
          Key: OS
          Value: ubuntu
Outputs:
  PublicIp:
    Value:
      Fn::GetAtt:
        - ubuntu
        - PublicIp
    Description: Server's PublicIp Address
STACK
}
