# FLUIDOS FlexSim

**Tagline:** Advanced Scheduling and Configuration Simulator for Resource Federation

## Overview

FLUIDOS FlexSim provides an emulation and simulation environment for validating FLUIDOS scheduling, orchestration, and resource federation strategies. It supports the creation of large-scale, on-demand test scenarios for experimental activities, including those difficult to reproduce in physical deployments. It is especially useful for testing security and privacy components, such as dynamic scheduling with trust and policy constraints.

## Installation

Run:
```shell
sudo ./ksim-installer.sh
```
to install the required dependencies and set up the environment:
- **Kwok**
- **Kind**
- **Liqoctl**
- **Kubectl**
- **Docker**
- Env variables and completion

Then run:
```shell
sudo install ksim /usr/local/bin
```
To install the binary.

## How to run

To run an introductory simulation follow the steps below (you can tab for completion):

- Initialize a **workspace** (Directory containing configurations and logs)
```shell
ksim initialize <workspace-name>
```
- Run a **simulation** on the workspace and log in human-readable and machine-readable form
```shell
ksim simulate <workspace-name> -l all # add a -v for verbosity
```
- Visualize what happened in the simulation by entering `<workspace-name>/logs/<cluster-name>`

> [!TIP]
> you can run a simulation for a workspace from everywhere, not just from the position of the workspace directory.
> If you lose track of your workspace, just run a `ksim list` command to list all the existing workspaces and their location.
