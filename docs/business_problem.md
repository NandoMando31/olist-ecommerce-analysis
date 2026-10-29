# Business Problem

## Context
Olist is a Brazilian online marketplace that connects small businesses with
customers across the country. This project analyzes a public snapshot of
about 100,000 orders placed between 2016 and 2018.

## Problem
Operations management suspects that late deliveries are driving down
customer reviews, but it does not know how much delivery delay matters,
or which stage of the process (seller handling or carrier transit) is
responsible for most of the delivery time.

## Decision to support
Decide where to intervene first: (a) pressure or replace carriers if
carrier transit dominates delivery time, or (b) set handling-time
requirements for sellers if seller handling dominates. A second decision
is whether the estimated delivery date shown at checkout should be revised.

## Key questions
1. What share of delivered orders arrive after the estimated delivery date?
2. Which segment (approval, seller handling, carrier transit) accounts for
   the largest median share of total delivery time?
3. How much does the average review score drop as delay increases?
4. Do orders that arrive early receive higher review scores than on-time
   orders, and how common are they?
5. Are orders with more items, or with heavier products, more likely to
   arrive after the estimated delivery date?

## Out of scope
- Review text (`review_comment_message`): no text analysis (NLP) in this project.
- Payment data (`olist_order_payments_dataset.csv`): payment type and installments
  do not relate to delivery performance or the questions above.
