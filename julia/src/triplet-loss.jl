
abstract type SelectingTripletMethod end

struct SelectRandom <: SelectingTripletMethod end
struct SelectHard <: SelectingTripletMethod end


function separateClasses(product_nodes, y, anchor, anchor_label)
    positives = [product_nodes[j] for j in 1:length(product_nodes) if y[j] == anchor_label && product_nodes[j] != anchor]
    negatives = [product_nodes[j] for j in 1:length(product_nodes) if y[j] != anchor_label]
    return positives, negatives
end

distance(pn1, pn2, metric) = only(metric(pn1, pn2))

# function mahalanobis(pn1, pn2, w)
 
#     x1 = only(pn1.data.x.data)
#     y1 = only(pn1.data.y.data)
#     x2 = only(pn2.data.x.data)
#     y2 = only(pn2.data.y.data)
    
#     return w[1]^2 * (x1 - x2)^2 + w[2]^2 * (y1 - y2)^2
# end

function selectTriplet(::SelectRandom, product_nodes, y, metric; α = 0.1)
    
    i = rand(1:length(product_nodes))
    anchor = product_nodes[i]
    anchor_label = y[i]

    positives, negatives = separateClasses(product_nodes, y, anchor, anchor_label)

    positive = rand(positives)
    negative = rand(negatives)

    return anchor, positive, negative
end

function selectTriplet(::SelectHard, product_nodes, y, metric; α = 0.1)

    triplets = []

    for i in 1:length(product_nodes)

        anchor = product_nodes[i]
        anchor_label = y[i]
        positives, negatives = separateClasses(product_nodes, y, anchor, anchor_label)

        for pos in positives
            d_pos = distance(anchor, pos, metric)

            for neg in negatives
                d_neg = distance(anchor, neg, metric)

                if d_neg < d_pos + α
                    push!(triplets, (anchor, pos, neg))
                end
            end
        end
    end

    return (length(triplets) == 0) ? nothing : triplets[rand(1:length(triplets))]
end

function splitData(X, y, numFolds)

    perm = Random.randperm(length(y))
    trn_len = Int64((1 - 1/numFolds) * length(y))

    X_perm = [X[:, i] for i in perm]
    y_perm = [y[i] for i in perm]

    X_trn = reduce(hcat, X_perm[1:trn_len, :])
    y_trn = y_perm[1:trn_len, :]

    X_tst = reduce(hcat, X_perm[trn_len + 1:end, :])
    y_tst = y_perm[trn_len + 1:end, :]

    return X_trn, y_trn, X_tst, y_tst
end

# TODO: which params to crossval
function crossval(X, y, params, numFolds) 

    X_train, y_train, X_test, y_test = splitData(X, y, 5)
    best_λ = Nothing
    bestScore = -Inf64
end

function tripletLoss(anchor, positive, negative, metric; α = 0.1, λₗₐₛₛₒ = 10.0)

    d_pos = distance(anchor, positive, metric)
    d_neg = distance(anchor, negative, metric)
    w = metric.weights.values

    return max(d_pos - d_neg + α, 0) + λₗₐₛₛₒ * sum(abs.(w))
end
