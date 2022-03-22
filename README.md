# Blockchain latency model and block size optimization #

Repository containing the files used to reproduce the results of the publication "End-to-End Latency Analysis and Optimal Block Size of Proof-of-Work Blockchain Applications".

''BibTeX'' citation:

```
@article{wilhelmi2022end,
  title={End-to-End Latency Analysis and Optimal Block Size of Proof-of-Work Blockchain Applications},
  author={Wilhelmi, Francesc, Barrachina-Mu\~noz, Sergio and Dini, Paolo},
  journal={arXiv preprint arXiv:2202.01497},
  year={2022}
}
```

## Table of Contents
- [Authors](#authors)
- [Publication's abstract](#abstract)
- [Repository description](#repository-description)
- [Usage](#usage)
- [Performance Evaluation](#performance-evaluation)
- [References](#references)
- [Contribute](#contribute)

## Authors
* [Francesc Wilhelmi](https://fwilhelmi.github.io/)
* [Sergio Barrachina-Muñoz](http://www.cttc.es/people/sbarrachina/)
* [Paolo Dini](http://www.cttc.es/people/pdini/)

## Abstract
Due to the increasing interest in blockchain technology for fostering secure, auditable, decentralized applications, a set of challenges associated with this technology need to be addressed. In this letter, we focus on the delay associated with Proof-of-Work (PoW)-based blockchain networks, whereby participants validate the new information to be appended to a distributed ledger via consensus to confirm transactions. We propose a novel end-to-end latency model based on batch-service queuing theory that characterizes timers and forks for the first time. Furthermore, we derive an estimation of optimum block size analytically. Endorsed by simulation results, we show that the optimal block size approximation is a consistent method that leads to close-to-optimal performance by significantly reducing the overheads associated with blockchain applications.

## Repository description
This repository contains the resources used to generate the results included in the paper entitled "End-to-End Latency Analysis and Optimal Block Size of Proof-of-Work Blockchain Applications". The files included in this repository are:

1. Matlab: scripts and code used to generate the results and plots included in the paper.

Notice that some of the results processed with Matlab scripts have been generated through the [batch-service queue simulator](https://github.com/fwilhelmi/batch_service_queue_simulator).

## Usage

### Part 1: End-to-end analysis framework

To generate the blockchain queue latency results, as well as to evaluate the proposed optimal block size function, we have used the end-to-end latency framework contained in this repository ("Matlab code/Model"). Those files contain the communication and computation models used to calculate the total latency experienced by PoW-based blockchains. 

To generate queue model results, we refer to function Matlab code/Model/queue_model_function.m, which needs the following input parameters:
- lambda_array: array with values of the total system arrivals in transactions per second
- mu: block generation rate in Hz
- queue_size: total size of the queue in number of transactions
- block_size: size of blocks in number of transactions
- timer: waiting timer in seconds for mining a block
- n_fork: ratio of expected forks for each generated block
- logs_enabled: variable to enable (1) or disable logs (0)

### Part 2: Batch service queue analysis

To generate the results related to the analysis of the queueing delay in the Blockchain, we used our [batch-service queue simulator](https://github.com/fwilhelmi/batch_service_queue_simulator) (commit: f846b66). Please, refer to that repository's documentation for installation/execution guidelines. As for the corresponding theoretical background, more details can be found in [1].

The obtained results from this part can be found at "Matlab code/simulation_data". To process them, execute the scripts at the "Matlab Code/scripts/2_validation_model_vs_simulator" folder.

## Performance Evaluation

### Simulation parameters

The simulation parameters used in the publication are as follows:

| **Parameter**                         | **Value**                         |
|---------------------------------------|-----------------------------------|
| Number of miners                      | 1, 10          	                  |
| Transaction size                      | 5 kbits                           |
| Block header size                     | 20 kbits                          |
| Max. waiting time                     | 1000 seconds                      |
| Queue length                          | 10 transactions                   |
| P2P link capacity                     | 5 Mbps                            |
| Sim. time                             | 100,000 seconds                   |
| Waiting timer                         | 0.1, 1, 5, 10, 100 s              |
| Packet arrivals                       | 0.1, 0.25, 0.5, 1, 2.5, 5, 1 tps  |
| Mining rate                           | 0.1, 0.25, 0.5, 1, 2.5, 5, 1 Hz   |

### Simulation Results

In what follows, we present the results presented in the manuscript. 

First, we show the accuracy of different interpolation mechanisms, which are used to approximate the optimal block size function. In particular, we focus on linear, quadratic, and Lagrangian interpolation functions.

<p align="center">
<img src="Matlab code/output/model_interpolation_extended.png" alt="" width="600"/>
</p>

Next, we show the transaction confirmation latency against the block size and highlight the range of validity of the optimal block size estimation.

<p align="center">
<img src="Matlab code/output/timer_vs_no_timer.png" alt="" width="600"/>
</p>

The validation of the queue model is done using simulations. The following figures compare the model output with simulation results, for different blockchain parameters.

<p align="center">
<img src="Matlab code/output/validation_complete_forks.png" alt="" width="600"/>
</p>

<p align="center">
<img src="Matlab code/output/validation_complete_no_forks_legend.png" alt="" width="600"/>
</p>

Finally, the following figure compares the performance obtained by the actual optimal block size (computed by brute force through simulations) and its model approximation.

<p align="center">
<img src="Matlab code/output/optimal_relative_difference.png" alt="" width="600"/>
</p>


## References

[1] Wilhelmi, F., & Giupponi, L. (2021). Discrete-Time Analysis of Wireless Blockchain Networks. arXiv preprint arXiv:2104.05586.


## Contribute

If you want to contribute, please contact to [fwilhelmi@cttc.cat](fwilhelmi@cttc.cat).

