/*
E. Bonus Questions
If Danny wants to expand his range of pizzas - how would this impact the existing data design? 
Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?
*/
-- If Danny wants to expand his range of pizzas, new records must be added to both the pizza_names table to define the new pizza and 
-- the pizza_recipes table to specify its corresponding toppings.
SELECT * 
FROM pizza_names; 

INSERT INTO pizza_names(pizza_id, pizza_name)
VALUES (3, 'Supreme'); 

SELECT * 
FROM pizza_recipes; 

INSERT INTO pizza_recipes(pizza_id, toppings)
SELECT 
	3, 
    GROUP_CONCAT(topping_id ORDER BY topping_id)
FROM pizza_toppings; 

