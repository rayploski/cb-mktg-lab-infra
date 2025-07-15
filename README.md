# Marketing Lab Nomad Jobs

This directory contains Nomad job specifications for services deployed in the `mktg-lab` datacenter. These jobs are defined in HCL and are intended to be run using [HashiCorp Nomad](https://www.nomadproject.io/) as part of a self-hosted infrastructure environment.

---

## Included Jobs

- **Ghost** – A modern, open-source headless CMS and blogging platform built on Node.js, ideal for publishers, writers, and membership sites.
- **Hugo** – A lightning-fast static site generator written in Go, supporting flexible templating, multilingual setups, and rapid builds.
- **MariaDB** – A community-driven, drop-in MySQL replacement offering enhanced performance, scalability, and full open-source licensing.
- **n8n** – A self-hostable workflow automation engine combining no-code and low-code capabilities with support for 400+ integrations.
- **PostgreSQL** – A powerful, extensible object-relational database system supporting SQL, JSON, full ACID compliance, and complex queries.
- **PostHog** – An open-source product analytics suite featuring session replay, feature flags, A/B testing, and event tracking.
- **ClickHouse** – A high-performance column-oriented OLAP database designed for real-time analytics on large volumes of data.
- **Redis** – An in-memory key-value store used for caching, real-time messaging, data structures, and fast data access patterns.
- **Strapi** – A flexible, open-source headless CMS built with Node.js, providing customizable APIs and fine-grained access control.
## Usage

To deploy a job:

```bash
nomad job run <job-file>


