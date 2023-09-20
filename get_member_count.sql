CREATE OR REPLACE FUNCTION get_member_count(
    p_subscription_id IN NUMBER,
    p_check_date IN DATE
) RETURN NUMBER
IS
    v_member_count NUMBER := 0;
    v_previous_date DATE;
    v_next_date DATE;
BEGIN
    -- Get the previous date with coverage
    SELECT MAX(subscription_date)
    INTO v_previous_date_new_again
    FROM subscription_dates
    WHERE subscription_id = p_subscription_id AND subscription_date <= p_check_date;

    -- Get the next date with coverage
    SELECT MIN(subscription_date)
    INTO v_next_date
    FROM subscription_dates
    WHERE subscription_id = p_subscription_id AND subscription_date > p_check_date;

    -- Count members based on continuous coverage or gaps
    IF v_previous_date IS NOT NULL AND v_next_date IS NOT NULL THEN
        -- Continuous coverage
        SELECT COUNT(*)
        INTO v_member_count
        FROM members
        WHERE subscription_id = p_subscription_id AND start_date <= p_check_date AND end_date > p_check_date;
    ELSIF v_previous_date IS NOT NULL THEN
        -- Coverage gap with no next date
        SELECT COUNT(*)
        INTO v_member_count
        FROM members
        WHERE subscription_id = p_subscription_id AND start_date <= p_check_date AND end_date > v_previous_date;
    ELSIF v_next_date IS NOT NULL THEN
        -- Coverage gap with no previous date
        SELECT COUNT(*)
        INTO v_member_count
        FROM members
        WHERE subscription_id = p_subscription_id AND start_date <= v_next_date AND end_date > p_check_date;
    END IF;

    RETURN v_member_count;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0; -- Subscription not found or no members
END;
/
In the above code, you need to have a table called subscription_dates that stores the subscription dates for each subscription_id. You also need a table called members that stores the members' details, including their start_date and end_date for each subscription.

To use the function, you can call it with the subscription_id and the check_date parameters. It will return the count of members covered by the subscription on that specific date.

Example usage:

sql
Copy code
DECLARE
    v_subscription_id NUMBER := 123;  -- Replace with your subscription ID
    v_check_date DATE := TO_DATE('2023-06-20', 'YYYY-MM-DD');  -- Replace with the date to check
    v_member_count NUMBER;
BEGIN
    v_member_count := get_member_count(v_subscription_id, v_check_date);
    DBMS_OUTPUT.PUT_LINE('Member count on ' || TO_CHAR(v_check_date, 'YYYY-MM-DD') || ': ' || v_member_count);
END;