#! /bin/bash
# Setup for freeCodeCamp's test
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

# Display services menu
    echo -e "\n~~~~~ MY SALON ~~~~~\n"
    echo -e "Welcome to My Salon, how can I halp you?\n"
MAIN_MENU() {

    SERVICES=$($PSQL "SELECT service_id, name FROM services;")
    echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
    do
        echo "$SERVICE_ID) $SERVICE_NAME"
    done

    read SERVICE_ID_SELECTED
    # if not a number, go back to menu
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
        echo I could not find that service. What would you like today?
        MAIN_MENU
    else
        SELECTED_SERVICE=$($PSQL "SELECT service_id, name FROM services 
                                WHERE service_id = $SERVICE_ID_SELECTED;")
        if [[ -z $SELECTED_SERVICE ]]
        then
            echo "I could not find that service. What would you like today?"
            MAIN_MENU
        fi

        # ask phone number
        echo "What's your phone number?"
        read CUSTOMER_PHONE
        
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers 
                                WHERE phone = '$CUSTOMER_PHONE'")
        # if new phone, ask name
        if [[ -z $CUSTOMER_NAME ]]
        then
            echo "I don't have a record for that phone number, what's your name?"
            read CUSTOMER_NAME

            # insert new customer
            INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) 
                                                VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
        fi

        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers 
                                WHERE phone = '$CUSTOMER_PHONE'")

        # ask time
        IFS="|" read -a array <<< "$SELECTED_SERVICE"
        SERVICE_NAME="${array[1]}"
        echo "What time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
        read SERVICE_TIME
        # insert service
        INSERT_TIME_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time)
            VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
        echo "I have put you down for a cut at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
}

MAIN_MENU
