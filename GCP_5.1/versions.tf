# Copyright (C) 2016-2024 Hammerspace, Inc.
# NOTICE: This software is subject to the terms of use posted here:
# http://www.hammerspace.com/company/EULA and you may only use this
# software if you are an authorized user. Your use of this software
# may be monitored and any unauthorized access or use may result in
# administrative, civil or criminal actions against you, under
# applicable law.

terraform {
    required_version = ">= 0.12.0"
    required_providers {
        google = {
        source  = "hashicorp/google"
        version = "5.42.0"
        }
    }
}