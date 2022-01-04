#!/bin/bash

export POSTGRES_HOST=postgres-primary.db-us-west-2-prod.com

export POSTGRES_PORT=5432
export POSTGRES_USER=stellarbot
export POSTGRES_DB=stellarbotdb

export POSTGRES_VERSION=12.8

export POSTGRES_PASSWORD=${POSTGRES_PASSWORD-'newborn-invasive-persona-maiden-asbestos-optic-croci-moralist-defat-juniper'}

export RDS_INSTANCE_TYPE=db.t3.small  # $0.036/hr
