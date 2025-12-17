# Software-Development-Notes

- [Software-Development-Notes](#software-development-notes)
  - [Repository Overview](#repository-overview)
  - [Repository Directory Structure](#repository-directory-structure)
    - [`bash-configuration`](#bash-configuration)
    - [`guake-configuration`](#guake-configuration)
    - [`neovim-configuration`](#neovim-configuration)
    - [`notes`](#notes)
    - [`scripts`](#scripts)
    - [`sublime-text-configuration`](#sublime-text-configuration)
    - [`vim-configuration`](#vim-configuration)
    - [`visual-studio-configuration`](#visual-studio-configuration)
  - [To Do List](#to-do-list)

## Repository Overview

This repository contains the notes and cheat sheets that have been compiled in the aims of learning new skills, tools,
and techniques related to software development. It also contains files to configure text editors that have been
identified and chosen for use. There is a Bash script written to configure and install software after a fresh
installation of a Linux distribution.

## Repository Directory Structure

The following is the outline of the directories in this repository:

### `bash-configuration`

`.bashrc` file containing overrides and aliases to ensure the consistency of commands and functionality in the
interactive shell sessions across Linux distributions.

### `guake-configuration`

`guake_configuration.conf` file containing the overrides required to configure the Guake text editor.

### `neovim-configuration`

`init.vim` file containing the overrides required to configure the Neovim text editor.

### `notes`

`Upskilling-Notes.md` file containing summaries and listing resource locations used to learn more about different
tools, technologies, and techniques related to software development.

### `scripts`

`linux_configuration_script.sh` script file required to install software across Debian, Arch, OpenSUSE, and Fedora
systems and set overrides. Note that in order to ensure each function in the script executes without any issue, you
will need to edit the script by removing each comment in the function callers at the bottom of each file. Run each of
the scripts in this directory by executing the following commands:

```bash
export SCRIPT_FILE_PATH="<Path to the script you wish to run>"
chmod +x "${SCRIPT_FILE_PATH}"
./"${SCRIPT_FILE_PATH}"
```

### `sublime-text-configuration`

`Preferences.sublime-settings` file containing the overrides required to configure the Sublime Text Editor.

### `vim-configuration`

`.vimrc` file containing the overrides required to configure the Vim text editor.

### `visual-studio-configuration`

JSON files containing the overrides required to configure the Visual Studio Code text editor.

## To Do List

- Add notes for the following resources in the `notes` directory:

  - Books:

    - Security:

      - [ ] 97 Things Every Application Security Professional Should Know (Humble Bundle)

  - Online:

    - Kubernetes:

      - Objects in Kubernetes:

        - [ ] Kubernetes Namespaces: <https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/>

        - [ ] Kubernetes Labels & Selectors:
          <https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/>

        - [ ] Kubernetes Finalizers: <https://kubernetes.io/docs/concepts/overview/working-with-objects/finalizers/>

      - Workloads:

        - [ ] Kubernetes Pods: <https://kubernetes.io/docs/concepts/workloads/pods/>

        - [ ] Kubernetes Sidecar Containers: <https://kubernetes.io/docs/concepts/workloads/pods/sidecar-containers/>

        - [ ] Kubernetes Ephemeral Containers:
          <https://kubernetes.io/docs/concepts/workloads/pods/ephemeral-containers/>

        - [ ] Kubernetes Pod Quality of Service Classes: <https://kubernetes.io/docs/concepts/workloads/pods/pod-qos/>

      - Configuration:

        - [ ] Kubernetes ConfigMaps: <https://kubernetes.io/docs/concepts/configuration/configmap/>

        - [ ] Kubernetes Liveness, Readiness, & Startup Probes:
          <https://kubernetes.io/docs/concepts/configuration/liveness-readiness-startup-probes/>

        - [ ] Kubernetes Secrets: <https://kubernetes.io/docs/concepts/configuration/secret/>

      - Cluster Architecture:

        - [ ] Kubernetes Nodes: <https://kubernetes.io/docs/concepts/architecture/nodes/>

      - Services, Load Balancing & Networking:

        - [ ] Kubernetes Services: <https://kubernetes.io/docs/concepts/services-networking/service/>

        - [ ] Kubernetes Ingresses: <https://kubernetes.io/docs/concepts/services-networking/ingress/>

        - [ ] Kubernetes Ingress Controllers:
          <https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/>

        - [ ] Kubernetes Network Policies: <https://kubernetes.io/docs/concepts/services-networking/network-policies/>

      - Workload Management:

        - [ ] Kubernetes Deployments: <https://kubernetes.io/docs/concepts/workloads/controllers/deployment/>

        - [ ] Kubernetes ReplicaSets: <https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/>

        - [ ] Kubernetes StatefulSets: <https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/>

        - [ ] Kubernetes DaemonSets: <https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/>

        - [ ] Kubernetes Jobs: <https://kubernetes.io/docs/concepts/workloads/controllers/job/>

        - [ ] Kubernetes CronJobs: <https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/>

- Follow the contents of the [Microservices with Node JS and React](
  https://www.udemy.com/course/microservices-with-node-js-and-react/?couponCode=LETSLEARNNOW) course on Udemy.

  - Save the changes and commits made to the script by creating a new Jira board and GitHub repository to contain and
    track the changes.

  - Document the notes from the course in the `notes` directory.

  - Instead of blindly following the content of the course, try and add additional tests and validation and endpoints
    to the code. Try and find alternative solutions to code, to learn more about the tools and technologies used to
    develop the microservices.

  - After the project has been implemented, add some variations of deploying the project, with different technologies,
    e.g., different message bus technologies and tools.

- Add notes for the following resources in the `notes` directory:

  - Books:

    - Security:

      - [ ] Cybersecurity Ops with `bash` (Humble Bundle)

      - [ ] Security Automation Detection Engineering (Humble Bundle)

      - [ ] Artificial Intelligence for Cybersecurity (Humble Bundle)

    - Automation:

      - [ ] Automate the Boring Stuff with Python: Practical Programming for Total Beginners, Second Edition
        (Humble Bundle)

        - Python Basics

        - Flow Control

        - Functions

        - Lists

        - Dictionaries and Structuring Data

        - Manipulating Strings

        - Pattern Matching with Regular Expressions

        - Input Validation

        - Reading and Writing Files

        - Organising Files

        - Debugging

        - Web Scraping

        - Working with Excel Spreadsheets

        - Working with Google Sheets

        - Working with PDF and Word Documents

        - Working with CSV Files and JSON Data

        - Keeping Time, Scheduling Tasks, and Launching Programs

        - Sending Email and Text Messages

      - [ ] Network Programmability and Automation (Humble Bundle), the following sections:

        - Network Industry Trends

        - Network Automation

        - Linux

        - Cloud

        - Network Developer Environments

        - Python

        - Go

        - Data Formats and Models

        - Working with Network APIs

        - Continuous Integration

        - Network Automation Architecture

    - Command Line:

      - `bash`

        - [ ] bash Cookbook (Humble Bundle)

      - PowerShell:

        - [ ] PowerShell Cookbook (Humble Bundle)

    - Professional Programmer Advice

      - [ ] The Pragmatic Programmer (Physical)

  - Online:

    - Pipelines:

      - Jenkins:

        - [ ] Jenkins Handbook: <https://www.jenkins.io/doc/book/>

        - [ ] Jenkins Guided Tour: <https://www.jenkins.io/doc/pipeline/tour/getting-started/>
