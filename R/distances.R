# ==============================================================================
# distances -- R package with tools for distance metrics
# https://github.com/fsavje/distances
#
# Copyright (C) 2017  Fredrik Savje -- http://fredriksavje.com
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see http://www.gnu.org/licenses/
# ==============================================================================


#' Constructor for distance metric objects
#'
#' \code{distances} constructs a distance metric for a set of points. Currently,
#' it only creates Euclidean distances. It can, however, create distances in any
#' linear projection of Euclidean space. In other words, Mahalanobis
#' distances or normalized Euclidean distances are both possible. It is also possible
#' to give each dimension of the space different weights.
#'
#' Let \eqn{x} and \eqn{y} be two data points in \code{data} described by two vectors. \code{distances}
#' uses the following metric to derive the distance between \eqn{x} and \eqn{y}:
#'
#' \deqn{\sqrt{(x - y) N^{-0.5} W (N^{-0.5})' (x - y)}}{\sqrt((x - y) * N^-0.5 * W * (N^-0.5)' * (x - y))}
#'
#' where \eqn{N^{-0.5}}{N^-0.5} is the Cholesky decomposition (lower triangular) of the inverse of the
#' matrix speficied by \code{normalize}, and \eqn{W} is matrix speficied by \code{weights}.
#'
#' When \code{normalize} is \code{var(data)} (i.e., using the \code{"mahalanobize"} option), the function gives
#' (weighted) Mahalanobis distances. When \code{normalize} is \code{diag(var(data))} (i.e., using
#' the \code{"studentize"} option), the function divides each column by its variance leading to (weighted) normalized
#' Euclidean distances. If \code{normalize} is the identity matrix (i.e., using the \code{"none"} or \code{NULL} option), the function
#' derives ordinary Euclidean distances.
#'
#' @param data a matrix or data frame containing the data points between distances should be derived.
#' @param id_variable optional IDs of the data points.
#'                    If \code{id_variable} is a single string and \code{data} is a data frame, the
#'                    corresponding column in \code{data} will be taken as IDs. That column will be
#'                    excluded from \code{data} when constructing distances (unless it is listed in
#'                    \code{dist_variables}). If \code{id_variable} is \code{NULL}, the IDs are set
#'                    to \code{1:nrow(data)}. Otherwise, \code{id_variable} must be of length
#'                    \code{nrow(data)} and will be used directly as IDs.
#' @param dist_variables optional names of the columns in \code{data} that should
#'                       be used when constructing distances. If \code{dist_variables} is \code{NULL},
#'                       all columns will be used (net of eventual column specified by \code{id_variable}).
#'                       If \code{data} is a matrix, \code{dist_variables} must be \code{NULL}.
#' @param normalize optional normalization of the data prior to distance construction. If \code{normalize}
#'                  is \code{NULL} or \code{"none"}, no normalization will be done (effectively setting \code{normalize}
#'                  to the identity matrix). If \code{normalize} is \code{"mahalanobize"}, normalization will be
#'                  done with \code{var(data)} (i.e., resulting in Mahalanobis distances). If \code{normalize} is
#'                  \code{"studentize"}, normalization is done with the diagonal of \code{var(data)}. If \code{normalize}
#'                  is a matrix, it will be used in the normalization. If \code{normalize} is a vector, a diagonal matrix
#'                  with the supplied vector as its diagonal will be used. The matrix used for normalization must be
#'                  positive-semidefinite.
#' @param weights optional weighting of the data prior to distance construction. If \code{normalize} is \code{NULL}
#'                no weighting will be done (effectively setting \code{weights} to the identity matrix). If \code{weights}
#'                is a matrix, that will be used in the weighting. If \code{normalize} is a vector, a diagonal matrix
#'                with the supplied vector as its diagonal will be used. The matrix used for weighting must be
#'                positive-semidefinite.
#'
#' @return Returns a \code{distances} object.
#'
#' @examples
#' my_data_points <- data.frame(x = c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10),
#'                              y = c(10, 9, 8, 7, 6, 6, 7, 8, 9, 10))
#'
#' # Euclidean distances
#' my_distances1 <- distances(my_data_points)
#'
#' # Euclidean distances in only one dimension
#' my_distances2 <- distances(my_data_points,
#'                            dist_variables = "x")
#'
#' # Mahalanobis distances
#' my_distances3 <- distances(my_data_points,
#'                            normalize = "mahalanobize")
#'
#' # Custom normalization matrix
#' my_norm_mat <- matrix(c(3, 1, 1, 3), nrow = 2)
#' my_distances4 <- distances(my_data_points,
#'                            normalize = my_norm_mat)
#'
#' # Give "x" twice the weight compared to "y"
#' my_distances5 <- distances(my_data_points,
#'                            weights = c(2, 1))
#'
#' # Use normalization and weighting
#' my_distances6 <- distances(my_data_points,
#'                            normalize = "mahalanobize",
#'                            weights = c(2, 1))
#'
#' # Custom ID labels
#' my_data_points_withID <- data.frame(my_data_points,
#'                                     my_ids = letters[1:10])
#' my_distances7 <- distances(my_data_points_withID,
#'                            id_variable = "my_ids")
#'
#'
#'
#' # Compare to standard R functions
#'
#' all.equal(as.matrix(my_distances1), as.matrix(dist(my_data_points)))
#' # > TRUE
#'
#' all.equal(as.matrix(my_distances2), as.matrix(dist(my_data_points[, "x"])))
#' # > TRUE
#'
#' tmp_distances <- sqrt(mahalanobis(as.matrix(my_data_points),
#'                                   unlist(my_data_points[1, ]),
#'                                   var(my_data_points)))
#' names(tmp_distances) <- 1:10
#' all.equal(as.matrix(my_distances3)[1, ], tmp_distances)
#' # > TRUE
#'
#' tmp_data_points <- as.matrix(my_data_points)
#' tmp_data_points[, 1] <- sqrt(2) * tmp_data_points[, 1]
#' all.equal(as.matrix(my_distances5), as.matrix(dist(tmp_data_points)))
#' # > TRUE
#'
#' tmp_data_points <- as.matrix(my_data_points)
#' tmp_cov_mat <- var(tmp_data_points)
#' tmp_data_points[, 1] <- sqrt(2) * tmp_data_points[, 1]
#' tmp_distances <- sqrt(mahalanobis(tmp_data_points,
#'                                   tmp_data_points[1, ],
#'                                   tmp_cov_mat))
#' names(tmp_distances) <- 1:10
#' all.equal(as.matrix(my_distances6)[1, ], tmp_distances)
#' # > TRUE
#'
#' tmp_distances <- as.matrix(dist(my_data_points))
#' colnames(tmp_distances) <- rownames(tmp_distances) <- letters[1:10]
#' all.equal(as.matrix(my_distances7), tmp_distances)
#' # > TRUE
#'
#' @export
distances <- function(data,
                      id_variable = NULL,
                      dist_variables = NULL,
                      normalize = NULL,
                      weights = NULL) {
  tmp_coerced_data <- coerce_distance_data(data, id_variable, dist_variables)
  data <- tmp_coerced_data$data
  id_variable <- tmp_coerced_data$id_variable
  rm(tmp_coerced_data)
  stopifnot(is.matrix(data),
            is.double(data))
  num_data_points <- nrow(data)

  if (!is.null(id_variable)) {
    id_variable <- coerce_character(id_variable, num_data_points)
  }

  if (is.character(normalize)) {
    if (normalize == "mahalanobis") normalize <- "mahalanobize"
    normalize <- coerce_args(normalize,
                             c("none",
                               "mahalanobize",
                               "studentize"))
    normalize <- switch(normalize,
                        none = NULL,
                        mahalanobize = stats::var(data),
                        studentize = diag(diag(stats::var(data))))
  }

  if (!is.null(normalize)) {
    normalize <- coerce_norm_matrix(normalize, ncol(data))
    data <- tcrossprod(data, chol(solve(normalize)))
  } else {
    normalize <- diag(ncol(data))
  }

  if (!is.null(weights)) {
    weights <- coerce_norm_matrix(weights, ncol(data))
    data <- tcrossprod(data, chol(weights))
  } else {
    weights <- diag(ncol(data))
  }

  structure(t(data),
            ids = id_variable,
            normalization = normalize,
            weights = weights,
            class = c("distances"))
}
