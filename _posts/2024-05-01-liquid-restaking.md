---
permalink: liquid-restaking-token
layout: post
title: "Building a liquid restaking token from first principles"
date: 2024-05-07 11:10:00 -0700

---

*By Sam Hart and Max Einhorn — thank you to Myles O’Neil, Krane, and Michael Ippolito for their thoughtful review*

---

Liquid restaking tokens (LRTs) are intermediary protocols built on top of slashing and execution primitives provided by restaking protocols, such as EigenLayer. The LRT protocol takes deposits from users and delegates those deposits to operators who in turn allocate this slashable collateral to a set of AVSs. The job of an LRT is to find promising AVSs and negotiate security agreements with them in exchange for a fixed portion of supply and ongoing rewards (e.g., airdrops, AVS token inflation, transaction fees, MEV, protocol fees). LRTs then pass these rewards back to depositors while pocketing a service fee. The designs of these LRTs vary in AVS contract structure, depositor incentives, and internalization of risk within the LRT asset construction. However, in speaking with many LRTs, we have found that most of their designs will make it impossible for them to uphold their commitments to their counterparties and will put the LRT’s solvency at risk. Moreover, in these conversations, we have identified gaps in the existing market structure for managing duration, efficiently utilizing capital, providing initial liquidity, and onboarding users, all of which will need to be addressed before the restaking market finds equilibrium. In this post, we articulate design decisions that LRTs can make to close these gaps.

# The gap between current LRT designs and the market

We’ll focus on four interrelated problems that LRTs could solve by modifying their protocol architecture to accommodate the prevailing market structure:

*1. Duration mismatch*

LRTs are committing to provide minimum amounts of security to AVSs for fixed durations. However, most LRT protocols have no controls for ensuring that depositors keep their capital deposited for the full duration of the security commitment.

*2. Underutilized capital*

There is far more deposited capital seeking a return than AVSs providing rewards. Many AVSs only need security in excess of the value susceptible to attack, which is often a function of volume rather than locked capital. Sophisticated actors will corner capacity constrained opportunities. Additionally, poor capital efficiency will depress returns, causing depositors to exit the system.

*3. Illiquid AVS tokens*

As AVSs launch tokens, they will need initial liquidity and price support, particularly as the sale of tokens will be used to cover operator costs until the service generates sufficient revenue. Moreover, if the AVS hosts DeFi functionality, it may further require liquidity to provide competitive rates or execution quality as the application is brought to market.

*4. Indirect user acquisition*

While some AVSs provide backend services to other protocols, many others will require building a retail customer base. Purchasing restaked security is often a means to indirectly access users who have made LRT deposits, where airdrops act as a user acquisition channel. In fact, it is unclear to what extent AVSs are paying for security vs. such auxiliary benefits valuable to their go-to-market. Executed poorly, these airdrops are costly, imprecise, and depress the AVS token price.

As we have seen with the Cosmos Hub’s Interchain Security offering, there are many other challenges that LRTs and restaking protocols will need to contend with, including upgrade coordination, operator incentive alignment, out-of-band payment structures, competitive dynamics among secured applications, efficient liquidation, and slashing claims adjudication. However, this post will focus exclusively on addressing the four concerns above.

# The LRT solution space

There are several key architectural patterns available to LRTs, which together encompass a large design space for alleviating our four identified problems:

*1. Managing duration with markets or rate limits*

Some depositors may be willing to make durational commitments in return for higher rewards, particularly institutional players or DAOs with extended time horizons. With longer commitments on the depositor side, the LRT would be able to safely make commitments to AVSs with comparable duration. Committed capital could be modulated by issuing bonds of discrete lengths and fractional reward allocations, thereby creating a market for interest rates. Alternatively, the LRT could put in place a withdrawal queue and structure a market for exit priority.

*2. Creating synthetic assets to maximize capital efficiency*

LRT protocols can reuse the capital backing their security guarantee as collateral to mint synthetic tokens that are pegged 1-to-1 with the deposited assets (e.g., synthetic ETH pegged to raw ETH). Given the complexity of underwriting AVS slashing, the LRT will want to maintain a buffer between synthetic assets issued and the real asset backing to ensure price parity. Alternatively, the LRT could issue synthetic assets that float relative to a given amount of asset backing and avoid defending a peg. In our research, many LRTs are opting to issue a floating asset to depositors. However, by incorporating deposit durations as indicated above, LRTs can safely retain some portion of synthetic tokens and put them to work for periods consistent with their committed capital.

*3. Providing a facility for AVS liquidity*

A key objective for AVSs is sourcing liquidity for the AVS’s native token. Rather than relying on a vague notion of alignment, LRTs can make their own treasury assets—or the synthetic assets they create—available to bootstrap liquidity for the AVS’s native token. The cost of liquidity provisioning could be expressed as an additional fee or amortized into the cost of AVS security provision. Taking this further, the LRT could also deploy the liquidity to strategically relevant destinations within the AVS’s DeFi economy, such as contributing to the supply side of a lending protocol to reduce interest rates and stimulate borrowing.

*4. Using token incentives to ensure user conversion*

Any AVSs that focus on retail applications will want to convert LRT depositors into users. The LRT could help AVSs solve this last mile user conversion problem by making it easy for their depositors to bridge into the AVS and receive a reward multiplier for performing actions desirable for AVS growth and retention. By stimulating continued AVS activity, user deposits will also remain locked in the LRT, providing an additional buffer against duration risk.

<figure>
  <img src="{{site.url}}/assets/liquid-restaking/lrt_cycle.png" alt="protocol relationships diagram"/>
  <figcaption>Figure 1. Introducing new protocol relationships to address the needs of Depositors, AVSs, and LRTs together.</figcaption>
</figure>

# Additional design considerations

There are numerous design decisions LRTs can make to differentiate their offering. In addition to the design decisions needed to address the core problems that we have already articulated, below are other major choices to consider.

*1. Payment conversion*

Restaking protocols may require payment in the same denomination as that of the security or liquidity provided (e.g. ETH for security via EigenLayer), however AVSs will often need to pay using their native tokens. Thus the AVS will need a way to convert these tokens to the desired payment denomination with minimal price impact (hint, Timewave solves this).

*2. Splitting principal from rewards (similar to Pendle)*

The LRT requires depositors to buy bonds with a duration to ensure that the capital is available to commit to AVSs for that duration. The LRT could split the bond into principal and interest tokens. Doing so would still accomplish the LRT’s goal of guaranteeing capital for a minimum duration while also providing depositors with rewards in the meantime.

*3. Variable security level*

An AVS might not want a fixed amount of security, but rather lease some amount of security that correlates with the value of the assets or liabilities secured. In such cases, the LRT and AVS could agree on a fee schedule that would determine how the parties provide services to one another as the AVS grows and the market conditions evolve. Additionally, the agreement could denominate the variable security in crypto rather than in USD.

*4. Generating a yield curve*

Most LRTs work with multiple AVSs who will want a variety of services and commitment durations. LRTs could translate the aggregate AVS demand for their services into a yield curve. Depositors would then decide the duration of their lockup based on the yield they are able to receive at various points along the yield curve. By increasing yield for durations with higher demand and lowering yield for durations with lower demand, LRTs can more efficiently match supply of depositor capital with AVS demand.


# Building intuition

<figure>
  <img src="{{site.url}}/assets/liquid-restaking/lrt_avs.png" alt="LRT-AVS diagram"/>
  <figcaption>Figure 2. Schematic of an LRT balancing AVS service demand and deposit duration.</figcaption>
</figure>

We started by modulating deposit incentives in response to AVS service demand, and conversely tempering service demand in response to capital stock, thereby constructing a control system to facilitate the desired equilibrium, safely and efficiently managing duration risk.

With the assurance we obtain around the duration of depositor capital commitments, the LRT can now issue synthetic assets that can be used to service AVS liquidity needs.

By extending the points regime to address last mile user conversion, LRTs organically obtain longer user deposits, helping them manage duration. Simultaneously they can provide AVSs seeking users greater support in advancing their growth objectives.

Our proposed LRT design space aims to give everyone more of what they want. AVSs get more liquidity and users alongside their security contract. Depositors get more rewards and are able to immediately utilize those rewards if a Pendle-style option is available. Meanwhile, LRTs are safer and make more money by attracting more deposits, engaging with a greater number of high quality AVSs, and charging for additional lines of business beyond security. Fundamentally, the way we achieve this is by recognizing that LRTs are not liquid instruments in the same way LSTs aim to be. Thus, building financial primitives that express duration and building a depositor-base with long-term conviction must be essential design goals.

# Next steps

*Shared liquidity*

In Timewave’s restaking work to date, we have already seen liquidity sharing agreements becoming a key lever for creating attractive security arrangements. Timewave’s Covenant system enables protocols to lend liquidity to other protocols trustlessly and programmatically. If you’d like to explore liquidity options for your LRT, we would love to talk about how we can collaborate.

*Balance sheet management*

Timewave’s Rebalancer enables cross-chain balance sheet management. If you are an AVS seeking to pay an LRT in a token different from your native token or if you are an LRT that is interested in converting native AVS tokens into a different token, we would be happy to work with you to ensure your balance sheet needs are met.

*Come talk to us*

Timewave team has experience designing and implementing the primary Cosmos liquid staking primitives and restaking system. Our technology facilitated the first ever trustless cross-chain agreements, and we have built tooling to streamline future agreements. Our products solve core pain points of deployed restaking systems. We have worked on every layer of the Cosmos stack and enjoy discussing where Cosmos may give a window into the future of other ecosystems. We would be happy to share our experience with you.

<br>Our DMs are open: [@timewavelabs](https://twitter.com/TimewaveLabs)

# Appendix: a prototype LRT construction

To understand the implications of the various architectural decisions made by the LRT designer, let’s build a LRT from the ground up in a way that addresses the four core problems. To set up the problem, we start with the following provisions:

| AVS Provision    | Amount |
| -------- | ------- |
| Amount of security that AVS wants  | $100mm   |
| Length of security agreement | 1 year   |
| LRT over-collateralization to maintain promised $USD level of security | 	20% |
| Interest AVS pays for synthetic ETH	 | 3% on borrowed synthetic ETH |
| Amount AVS pays for security	 | 2% on the USD amount of committed security  |
| Amount AVS offers depositors via points	 | 1% on depositor capital |
| LRT fee charged to depositors | 	0.5% of deposited capital |
|  LRT fee paid to restaking protocol	 | 0.25% of deposited capital |

The design begins with an LRT protocol and an AVS that are interested in working together. The AVS wants security and liquidity. The LRT wants increased rewards so that it can attract more depositor capital, which will result in increased revenue for the LRT since it charges a fee on deposited capital.

Specifically, the AVS wants $100mm worth of security and $85mm worth of ETH liquidity for one year. The LRT satisfies these needs by selling $120mm worth of 1-year duration bonds to depositors—bond holders receive the profits made via security and liquidity lending. The LRT sells more than $100mm worth of bonds as a buffer to ensure that it will be able to continue meeting its $100mm security obligation to the AVS even if the price of ETH falls in dollar terms. The LRT does not have to worry about early depositor withdrawal because the depositors are locked for one year. The AVS pays the LRT 2% on the $USD amount of committed security annually for the security it is borrowing.

The LRT then creates $85mm worth of synthetic ETH using the $120mm of deposited ETH as collateral and uses the $85mm worth of synthetic ETH to bootstrap liquidity for the AVS’s native token. The difference between the amount of synthetic ETH that the LRT creates and the amount of raw ETH it has in collateral is the buffer that ensures that the peg between the synthetic ETH and real ETH remains stable. The AVS pays the 3% annual interest to the LRT for the liquidity that the LRT is using to bootstrap liquidity for the AVS’s native token.

To incentivize user adoption, the AVS also offers depositors a multiplier on the points depositors receive by engaging in desirable activity on the AVS (e.g., participating in DeFi). This multiplier results in sending depositors an additional 1% of the depositors’ capital back to the depositors in the form of points that will ultimately convert to token claims.

The LRT passes all revenue generated via the 3% liquidity interest, 2% security fee, and 1% points bonus to the bond holders minus the restaking protocol’s security fee of 0.25% and the LRT’s fee of 0.5%. The LRT also retains any profits it makes in the process of liquidity bootstrapping (e.g. interest on loans, fees on LP positions).

To summarize, the AVS-LRT deal mechanics consist of the following:

- LRT sells $120mm ($100mm * 120%) worth of 1-year duration bonds to depositors.
- AVS pays LRT $2.55mm ($85mm * 3%) worth of tokens in interest over one year for the LRT’s bootstrapping of the AVS’s native token.
- AVS pays $2mm ($100mm * 2%) worth of tokens to the LRT for security over one year.
- AVS pays $1.2mm ($120mm * 1%) worth of points to the LRT depositors over one year.
- The LRT pays the restaking protocol $300k ($120mm * 0.25%) for the use of the restaking protocol’s technology to provide security to the AVS over one year.
- The LRT retains $600k in revenue ($120mm * 0.5%) over one year for engaging in all the activity necessary to generate the rewards that are high enough to attract $120mm worth of deposits.
- Depositors receive total profit of $4.85mm over one year ($2.55mm + $2mm + $1.2mm - $300k - $600k), which is means a 4.04% rewards rate ($4.85mm / $120mm).
