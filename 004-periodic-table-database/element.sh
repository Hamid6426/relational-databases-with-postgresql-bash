#!/bin/bash

# Set up the variable to access the database;
PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"

# First check that we got an argument, if not print the specified message and exit.
if [[ -z $1 ]]
then
# This is the error condition and we exit...
  echo -e "Please provide an element as an argument."
else
# An argument was passed, was it a number?
  if [[ $1 =~ ^[0-9]+$ ]]
  then
# Passed an atomic number.
    ELEMENTINFO=$($PSQL "SELECT atomic_number, symbol, name, atomic_mass, melting_point_celsius, boiling_point_celsius, type FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE atomic_number = '$1'")

  elif [[ $1 =~ ^[A-Z][a-z]?$ ]]
  then
# Passed a symbol.
    ELEMENTINFO=$($PSQL "SELECT atomic_number, symbol, name, atomic_mass, melting_point_celsius, boiling_point_celsius, type FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE symbol = '$1'")
  else
# Passed an element name.
    ELEMENTINFO=$($PSQL "SELECT atomic_number, symbol, name, atomic_mass, melting_point_celsius, boiling_point_celsius, type FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE name = '$1'")
  fi
# Test ELEMENTINFO if empty then we coouldn't find the argument that was passed.
  if [[ -z $ELEMENTINFO ]]
  then
    echo -e "I could not find that element in the database."
  else
# Remove padding in the row of data with sed.
    ELEMENTINFO=$(echo $ELEMENTINFO | sed 's/ //g')      
    echo $ELEMENTINFO | while IFS=\| read NUMBER SYMBOL NAME ATOMIC_MASS MELTING_POINT_C BOILING_POINT_C TYPE
    do
# Finally we can report the results to the user...
    echo -e "The element with atomic number $NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT_C celsius and a boiling point of $BOILING_POINT_C celsius."
    done
  fi
fi
