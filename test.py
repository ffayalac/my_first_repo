import numpy as np

def calculate_mean(data):
    """
    Calculate the mean of a list of numbers.

    Parameters:
    data (list): A list of numerical values.

    Returns:
    float: The mean of the input data.
    """
    if not data:
        raise ValueError("The data list is empty.")
    
    return np.mean(data)