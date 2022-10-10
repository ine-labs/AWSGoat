#!/bin/bash

#Adding cluster name in ecs config
echo ECS_CLUSTER=ecs-lab-cluster >> /etc/ecs/ecs.config
cat /etc/ecs/ecs.config | grep "ECS_CLUSTER"