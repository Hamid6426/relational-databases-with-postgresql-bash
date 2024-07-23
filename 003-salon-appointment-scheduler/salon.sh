#!/bin/bash

# Connect to the database
PSQL="psql --username=freecodecamp --dbname=salon -f salon.sql -t --no-align -c"

# Function to display the services
display_services() {
  echo "Here are the services we offer:"
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICES" | while IFS='|' read SERVICE_ID SERVICE_NAME; do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
}

# Function to prompt for service selection and handle input
get_service_id() {
  display_services
  echo "Please enter the service ID for the service you want:"
  read SERVICE_ID_SELECTED

  # Check if the entered service ID is valid
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  if [[ -z $SERVICE_NAME ]]; then
    echo "Invalid service ID. Please try again."
    get_service_id
  fi
}

# Prompt for service ID
get_service_id

# Prompt for customer phone number
echo "Please enter your phone number:"
read CUSTOMER_PHONE

# Check if customer exists
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

# If customer does not exist, prompt for name and add to customers table
if [[ -z $CUSTOMER_ID ]]; then
  echo "You are not in our system. Please enter your name:"
  read CUSTOMER_NAME

  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  if [[ $INSERT_CUSTOMER_RESULT == "INSERT 0 1" ]]; then
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  fi
else
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID")
fi

# Prompt for service time
echo "Please enter the time for your appointment:"
read SERVICE_TIME

# Insert appointment into appointments table
INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

# Confirm the appointment
if [[ $INSERT_APPOINTMENT_RESULT == "INSERT 0 1" ]]; then
  echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
fi
