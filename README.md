# FLUIDOS FlexSim

**Tagline:** Advanced Scheduling and Configuration Simulator for Resource Federation

## Overview

FLUIDOS FlexSim provides an emulation and simulation environment for validating FLUIDOS scheduling, orchestration, and resource federation strategies. It supports the creation of large-scale, on-demand test scenarios for experimental activities, including those difficult to reproduce in physical deployments. It is especially useful for testing security and privacy components, such as dynamic scheduling with trust and policy constraints.

## Installation

Run:
```shell
sudo ./flexsim-installer.sh
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
sudo install flexsim /usr/local/bin
```
To install the binary.

## How to run

To run an introductory simulation follow the steps below (you can tab for completion):

- Initialize a **workspace** (Directory containing configurations and logs)
```shell
flexsim initialize <workspace-name>
```
- Run a **simulation** on the workspace and log in human-readable and machine-readable form
```shell
flexsim simulate <workspace-name> -l all # add a -v for verbosity
```
- Visualize what happened in the simulation by entering `<workspace-name>/logs/<cluster-name>`

> [!TIP]
> you can run a simulation for a workspace from everywhere, not just from the position of the workspace directory.
> If you lose track of your workspace, just run a `flexsim list` command to list all the existing workspaces and their location.

## Examples
The `examples/` folder provides ready-to-use configuration (`configs`) files to run FLUIDOS-FlexSim in different scales. These can be used as starting points for testing orchestration, scheduling, and federation strategies. The folder also contains logs (`logs`) of the respective simulations, where it is possible to inspect metrics, events, and other relevant steps and data generated during the experiments.

- **Small scenario** (`examples/small-scenario`):
  Defines a minimal environment with a limited number of nodes and services. It is useful for quickly validating functionality, debugging, or running lightweight simulations.
  The simulated infrastructure is composed by three FLUIDOS nodes: located in Italy, Germany, and Ireland. The Ireland node act as consumer, while German and Italian nodes act as providers with 5 Kubernetes worker each.

- **Large scenario** (`examples/large-scenario`):
  Provides a configuration with a larger number of nodes, resources, and policies. This setup is designed to test scalability, stress orchestration mechanisms, and evaluate performance under more realistic or complex workloads.
  The simulated infrastructure is composed by three FLUIDOS nodes: located in Italy, Germany, and Ireland. The Ireland node act as consumer, while German and Italian nodes act as providers with 5000 Kubernetes worker each.

You can run these scenarios by passing the worksapce-name to the simulator, for example:

```shell
flexsim simulate small-scenario -l all -v
flexsim simulate small-scenario -l all -v
```

> [!TIP]
> - Because the large scenario can be resource-intensive, it may be prudent to run on a machine with more memory/CPUs.
> - You can adapt the example configuration files to your custom test cases (e.g. adjust node counts, resource capacities and thresholds).
> - For reproducibility and statistical significance, run multiple replicates of the same scenario and aggregate results.