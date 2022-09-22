#int_orders__pivoted.sql
{%- set payment_methods = ['bank_transfer', 'credit_card', 'coupon', 'gift_card'] -%}

with payments as (
   select * from {{ ref('stg_payments') }}
),

final as (
   select
       order_id,
       {% for payment_method in payment_methods -%}

       sum(case when payment_method = '{{ payment_method }}' then amount else 0 end) as {{ payment_method }}_amount

       {%- if not loop.last -%}
         ,
       {% endif -%}

       {%- endfor %}
   from {{ ref('stg_payments') }}
   group by 1
)

select * from final
----------------------------------------------------------------------------------------------

Enable fullscreen
Review
Jinja 
Jinja a templating language written in the python programming language. Jinja is used in dbt to write functional SQL. For example, we can write a dynamic pivot model using Jinja.

Jinja Basics
The best place to learn about leveraging Jinja is the Jinja Template Designer documentation.

There are three Jinja delimiters to be aware of in Jinja.

{% … %} is used for statements. These perform any function programming such as setting a variable or starting a for loop.
{{ … }} is used for expressions. These will print text to the rendered file. In most cases in dbt, this will compile your Jinja to pure SQL.
{# … #} is used for comments. This allows us to document our code inline. This will not be rendered in the pure SQL that you create when you run dbt compile or dbt run.
A few helpful features of Jinja include dictionaries, lists, if/else statements, for loops, and macros.

Dictionaries are data structures composed of key-value pairs.

{% set person = {
    ‘name’: ‘me’,
    ‘number’: 3
} %}

{{ person.name }}

me

{{ person[‘number’] }}

3
Lists are data structures that are ordered and indexed by integers.

{% set self = [‘me’, ‘myself’] %}

{{ self[0] }}

me
If/else statements are control statements that make it possible to provide instructions for a computer to make decisions based on clear criteria.

{% set temperature = 80.0 %}

On a day like this, I especially like

{% if temperature > 70.0 %}

a refreshing mango sorbet.

{% else %}

A decadent chocolate ice cream.

{% endif %}

On a day like this, I especially like

a refreshing mango sorbet
For loops make it possible to repeat a code block while passing different values for each iteration through the loop.

{% set flavors = [‘chocolate’, ‘vanilla’, ‘strawberry’] %}

{% for flavor in flavors %}

Today I want {{ flavor }} ice cream!

{% endfor %}

Today I want chocolate ice cream!

Today I want vanilla ice cream!

Today I want strawberry ice cream!
Macros are a way of writing functions in Jinja. This allows us to write a set of statements once and then reference those statements throughout your code base.

{% macro hoyquiero(flavor, dessert = ‘ice cream’) %}

Today I want {{ flavor }} {{ dessert }}!

{% endmacro %}

{{ hoyquiero(flavor = ‘chocolate’) }}

Today I want chocolate ice cream!

{{ hoyquiero(mango, sorbet) }}

Today I want mango sorbet!
Whitespace Control
We can control for whitespace by adding a single dash on either side of the Jinja delimiter. This will trim the whitespace between the Jinja delimiter on that side of the expression.

Bringing it all Together!
We saw that we could refactor the following pivot model in pure SQL using Jinja to make it more dynamic to pivot on a list of payment methods.

Original SQL:

with payments as (
   select * from {{ ref('stg_payments') }}
),
 
final as (
   select
       order_id,
 
       sum(case when payment_method = 'bank_transfer' then amount else 0 end) as bank_transfer_amount,
       sum(case when payment_method = 'credit_card' then amount else 0 end) as credit_card_amount,
       sum(case when payment_method = 'coupon' then amount else 0 end) as coupon_amount,
       sum(case when payment_method = 'gift_card' then amount else 0 end) as gift_card_amount
 
   from payments
 
   group by 1
)
 
select * from final
Refactored Jinja + SQL:

{%- set payment_methods = ['bank_transfer','credit_card','coupon','gift_card'] -%}
 
with payments as (
   select * from {{ ref('stg_payments') }}
),
 
final as (
   select
       order_id,
       {% for payment_method in payment_methods -%}
 
       sum(case when payment_method = '{{ payment_method }}' then amount else 0 end) 
            as {{ payment_method }}_amount
          
       {%- if not loop.last -%}
         ,
       {% endif -%}
 
       {%- endfor %}
   from payments
   group by 1
)
 
select * from final
----------------------------------------------------------------------------------------------
--macros!
--https://docs.getdbt.com/docs/dbt-cloud/using-dbt-cloud/cloud-setting-a-custom-target-name#dbt-cloud-ide
Exemplar
macros/cents_to_dollars.sql

{% macro cents_to_dollars(column_name, decimal_places=2) -%}
    round( 1.0 * {{ column_name }} / 100, {{ decimal_places }})
{%- endmacro %}

Refactored stg_payments.sql

select
    id as payment_id,
    orderid as order_id,
    paymentmethod as payment_method,
    status,
    -- amount is stored in cents, convert it to dollars
    {{ cents_to_dollars('amount', 4) }} as amount,
    created as created_at
from {{ source('stripe','payment') }}
--
Review
Macros
Macros are functions that are written in Jinja. This allows us to write generic logic once, and then reference that logic throughout our project.

Consider the case where we have three models that use the same logic. We could copy paste the logic between those three models. If we want to change that logic, we need to make the change in three different places.

Macros allow us to write that logic once in one place and then reference that logic in those three models. If we want to change the logic, we make that change in the definition of the macro and this is automatically used in those three models.

DRY Code
Macros allow us to write DRY (Don’t Repeat Yourself) code in our dbt project. This allows us to take one model file that was 200 lines of code and compress it down to 50 lines of code. We can do this by abstracting away the logic into macros.

Tradeoff
As you work through your dbt project, it is important to balance the readability/maintainability of your code with how concise your code (or DRY) your code is. Always remember that you are not the only one using this code, so be mindful and intentional about where you use macros.

Macro Example: Cents to Dollars
Original Model:

select
    id as payment_id,
    orderid as order_id,
    paymentmethod as payment_method,
    status,
    -- amount stored in cents, convert to dollars
    amount / 100 as amount,
    created as created_at
from {{ source(‘stripe’, ‘payment’) }}
New Macro:

{% macro cents_to_dollars(column_name, decimal_places=2) -%}
round( 1.0 * {{ column_name }} / 100, {{ decimal_places }})
{%- endmacro %}
Refactored Model:

select
    id as payment_id,
    orderid as order_id,
    paymentmethod as payment_method,
    status,
    -- amount stored in cents, convert to dollars
    {{ cents_to_dollars(‘payment_amount’) }} as amount
    created as created_at
from {{ source(‘stripe’, ‘payment’) }}
----------------------------------------------------------------------------------------------
Packages!!
https://hub.getdbt.com/
----------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
