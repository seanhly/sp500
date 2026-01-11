import pandas as pd
from xgboost import DMatrix, train, XGBRegressor, XGBClassifier
from sklearn.model_selection import train_test_split

# Load data from CSV file
data = pd.read_csv('train2.csv')

# Separate features and target
X = data.drop('y', axis=1).drop('date', axis=1)
y = data['y']

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.1, random_state=43
)

#params = {
#    'objective': 'reg:squarederror',
#    'learning_rate': 0.1,
#    'random_state': 42,
#}

# Train the model
model = XGBClassifier(n_estimators=500, max_depth=40)
#model = XGBRegressor(n_estimators=500, max_depth=40)
model.fit(X_train, y_train)
y_probs = model.predict_proba(X_test)[:,1]
THRESHOLD = 0.2
preds = (y_probs >= THRESHOLD).astype(int)
print("actual", "predicted", sep=",")
for actual, predicted in zip(y_test, preds):
    print(actual, predicted, sep=",")
