with payment as (

    select
        *
    from `dbt-tutorial.stripe.payment`

)
select * from payment