#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

if [[ -z $USER_ID ]]
then
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
else
    GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id=$USER_ID")
    BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id=$USER_ID")
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
GUESSES=0

echo "Guess the secret number between 1 and 1000:"
while read GUESS
do
    if [[ ! $GUESS =~ ^[0-9]+$ ]]
    then
        echo "That is not an integer, guess again:"
        continue
    fi

    (( GUESSES++ ))

    if (( GUESS == SECRET_NUMBER ))
    then
        echo "You guessed it in $GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
        break
    elif (( GUESS < SECRET_NUMBER ))
    then
        echo "It's higher than that, guess again:"
    else
        echo "It's lower than that, guess again:"
    fi
done

UPDATE_USER_RESULT=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE user_id=$USER_ID")

BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id=$USER_ID")
if [[ -z $BEST_GAME ]] || (( GUESSES < BEST_GAME ))
then
    UPDATE_BEST_GAME_RESULT=$($PSQL "UPDATE users SET best_game=$GUESSES WHERE user_id=$USER_ID")
fi

INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, $GUESSES)")
