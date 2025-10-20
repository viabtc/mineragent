# MinerAgent

English | [简体中文](./README.md) | [Русский](./README.ru.md)

## Is It Necessary to Set Up an Agent Server?

In large-scale mining farms with thousands of miners, directly connecting miners to the pool address may cause a higher rejection rate due to network instability. This is especially evident during pool task switches. If the farm’s network is unstable, miners may continue working on outdated tasks after the pool has already switched, leading to wasted hashrate.

By installing an agent server in the mining farm, the pool distributes tasks to the server first, which then distributes them to miners. Similarly, miners submit results to the server, which then submits them to the pool. This significantly improves mining stability and reduces rejection rates.

If you operate a large-scale mining farm managing substantial hashrate, you should consider deploying your own mining agent server.

## Benefits of an Agent Server

1. The agent server handles task distribution and submission, allowing miners to focus on mining.
2. Reduces bandwidth consumption, freeing up network resources for both the pool and the farm.
3. Improves mining stability and minimizes hashrate waste caused by network issues.

Note: The agent server currently supports only BTC and LTC.

## Preparations

Before deploying a mining agent server, ensure the following:
A computer (Windows or Ubuntu) with internet access to deploy the agent server
Both the computer and the mining machines must be on the same local area network (LAN).
Note: Once configured, this computer will function as the mining agent server and must keep MinerAgent running for long periods of time.
