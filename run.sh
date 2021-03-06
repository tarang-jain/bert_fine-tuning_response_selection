#!/bin/bash

#Flags
preprocess=1               #set to 1 if data processing needed
encode_data=1              #set to 1 if embeddings are not already created and saved
run_question_answering=1   #set to 1 to converse with the model

question_beam=50 #number of <question, answer> pairs to be searched

printf "\n"

#First start the bert service in new terminal window

if [ $preprocess -eq 1 ]; then
printf "\n"
echo ============================================================================
echo "                          Preprocessing Corpus                            "
echo ============================================================================

python3 preprocess.py

mv "cornell movie-dialogs corpus" "cornell_movie-dialogs_corpus"
corpus_dir="cornell_movie-dialogs_corpus"

printf "\n"
echo "Preparing eval questions ..."
eval_len=5000
total_len=$(cat $corpus_dir/preprocessed_q.txt|wc -l)
training_len=$((total_len - eval_len))
tail -n $eval_len $corpus_dir/preprocessed_q.txt > $corpus_dir/preprocessed_q_eval.txt
head -n $training_len $corpus_dir/preprocessed_q.txt > $corpus_dir/preprocessed_q_train.txt

printf "\n"
echo "Preparing eval answers ..."
tail -n $eval_len $corpus_dir/preprocessed_a.txt > $corpus_dir/preprocessed_a_eval.txt
head -n $training_len $corpus_dir/preprocessed_a.txt > $corpus_dir/preprocessed_a_train.txt

mv "cornell_movie-dialogs_corpus" "cornell movie-dialogs corpus"

fi

if [ $encode_data -eq 1 ]; then
printf "\n"
echo ============================================================================
echo "         Embedding movie lines as vectors using bert-as-service           "
echo ============================================================================

python3 encode_data.py

fi

if [ $run_question_answering -eq 1 ]; then
printf "\n"
echo ============================================================================
echo "                      Run question answering (inference)                  "
echo ============================================================================

python3 converse.py --beam=$question_beam

fi

