loans = [
    # (23105.52, 5.490),
    (5028.00, 3.250),
    # (2864.39, 4.120),
    # (9266.71, 4.120),
    (4711.50, 3.870),
    (10122.31, 3.000),
    # (4939.51, 5.8),
    (2251.18, 2.65),
    (2251.19, 2.65),
    (5515.11, 3.86),
    (7975.74, 3.86),
    # (4982.00, 4.660),
    # (8434.00, 4.660),
    (13366.95, 4.29),
    (3126.00, 3.76),
    (7656.06, 3.76)
    ]
total = sum(l[0] for l in loans)
print(total)
weighted = [(loan[0], loan[1], loan[0] / total) for loan in loans]
weight_avg = sum(loan[1] * loan[2] for loan in weighted)
print(weight_avg)
