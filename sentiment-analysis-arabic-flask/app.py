import json
import aranorm as aranorm
from flask import Flask, request, jsonify
import numpy as np
from sklearn.feature_extraction.text import TfidfVectorizer, CountVectorizer
from sklearn.svm import SVC
from sklearn.neural_network import MLPClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.naive_bayes import MultinomialNB, GaussianNB
import pickle
from flask import Flask, flash, request, redirect, url_for
from werkzeug.utils import secure_filename

app = Flask(__name__)

models_folder = 'sentiment-analysis-arabic-flask/models/'
models_folder = models_folder.rstrip('/')

vectorizer = pickle.load(open(f'{models_folder}/vectorizer.pkl', 'rb'))
mnb = pickle.load(open(f'{models_folder}/mnb.pkl', 'rb'))
neu_vectorizer = pickle.load(open(f'{models_folder}/neu_vectorizer.pkl', 'rb'))
neu_svm = pickle.load(open(f'{models_folder}/neu_svm.pkl', 'rb'))


##############################################################################################################

def predict_multi_level(X, neu_vectorizer, neu_clf, vectorizer, clf):
    return clf.predict(vectorizer.transform(X))
    neu_y_pred = neu_clf.predict(neu_vectorizer.transform(X))
    if len(X[neu_y_pred == 'NonNeutral']) > 0:
        # classify non neutral into positive or negative
        y_pred = clf.predict(vectorizer.transform(
            X[neu_y_pred == 'NonNeutral']))
        neu_y_pred[neu_y_pred == 'NonNeutral'] = y_pred

    final_y_pred = neu_y_pred
    return final_y_pred

##############################################################################################################


array = {"output": ""}


@app.route('/', methods=['GET', 'POST'])
def index():
    finalResult = ""
    request_data = json.loads(request.data.decode('utf-8'))
    text_form_app = request_data['text']
    print(text_form_app)

    # check if the post request has the file part
    # if 'input_text' not in request.form:
    #     flash('No text found!')
    #     return redirect(request.url)

    # text = request.form['input_text']
    # text = aranorm.normalize_arabic_text(text)

    predcited_sentiment = predict_multi_level(
        np.array([text_form_app]), neu_vectorizer, neu_svm, vectorizer, mnb)
    predcited_sentiment = str(predcited_sentiment.squeeze())

    print(f'text: {text_form_app}')
    print("Predicted Sentiment:", predcited_sentiment)

    array['sentiment'] = predcited_sentiment

    return jsonify(array)


if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=False)
