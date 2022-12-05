from flask import Flask, request, jsonify
import json
from tensorflow.python.keras.models import load_model
from keras.models import model_from_json
import numpy as np
from keras.preprocessing.text import Tokenizer
import keras.preprocessing.text as kpt

tokenizer = Tokenizer(num_words=1000)

labels = ['negative', 'positive']

# load sentiment model
json_file = open('1000w-model.json', 'r')
loaded_model_json = json_file.read()
json_file.close()
model = model_from_json(loaded_model_json)
model.load_weights('1000w-model.h5')


# load json file
with open("dictionary.json") as json_file:
    json_tokenizer = json.load(json_file)


with open('dictionary.json', 'r') as dict_file:
    dictionary = json.load(dict_file)


def convert_text_to_index_array(text):
    words = kpt.text_to_word_sequence(text)
    wordIndices = []
    for word in words:
        if word in dictionary:
            wordIndices.append(dictionary[word])
        else:
            print("'%s' not in training corpus; ignoring." % (word))

    return wordIndices


# Crete an instance of this class
app = Flask(__name__)
app.config['PROPAGATE_EXCEPTIONS'] = True

array = {"output": ""}
# use the route() decorator to tell Flask what url should trigger our function


@app.route('/', methods=['POST', 'GET'])
def index():
    finalResult = ""
    request_data = json.loads(request.data.decode('utf-8'))
    text_form_app = request_data['text']
    print(text_form_app)

    testArr = convert_text_to_index_array(text_form_app)
    uinput = tokenizer.sequences_to_matrix([testArr], mode='binary')

    pred = model.predict(uinput)

    sentiment_score = model.predict(uinput)
    print(sentiment_score[0][0])

    finalResult = labels[np.argmax(pred)]

    array['sentiment'] = finalResult
    array['score'] = str(pred[0][np.argmax(pred)] * 100)

    return jsonify(array)


if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=False)
