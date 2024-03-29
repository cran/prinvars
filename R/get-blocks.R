get_blocks <- function(threshold_matrix, feature_names, check) {
  num_features <- nrow(threshold_matrix)
  untaken_features <- 1:num_features
  untaken_evs <- seq_len(ncol(threshold_matrix))
  zero_counts <- get_zero_count(threshold_matrix)
  ones <- 1
  blocks <- list()

  while (length(untaken_features) > 0 && ones <= length(untaken_features)) {
    eligible_features <- get_eligible_features(
      zero_counts=zero_counts,
      zeros=num_features - ones,
      untaken_features=untaken_features
    )

    while (length(eligible_features) >= ones) {
      combination <- find_combination(
        threshold_matrix=threshold_matrix,
        eligible_features=eligible_features,
        ones=ones,
        current_combination=c(),
        check=check,
        taken_features=setdiff(c(1:num_features), untaken_features)
      )

      if (!is.atomic(combination)) {
        is_valid <- combination$is_valid
        ev_influenced <- combination$ev_influenced
        combination <- combination$combination

        blocks[[length(blocks) + 1]] <- create_block(
          feature_names=feature_names,
          selected_features=combination,
          is_valid=is_valid,
          ev_influenced=ev_influenced
        )
        eligible_features <- eligible_features[
          !eligible_features %in% combination
        ]
        untaken_evs <- untaken_evs[!untaken_evs %in% ev_influenced]
        untaken_features <- untaken_features[!untaken_features %in% combination]
      } else {
        eligible_features <- eligible_features[-1]
      }
    }

    ones <- ones+1
  }

  if(length(untaken_features) > 0) {
    blocks[[length(blocks) + 1]] <- create_block(
      feature_names=feature_names,
      selected_features=untaken_features,
      is_valid=FALSE,
      ev_influenced=untaken_evs
    )
  }

  return(blocks)
}

find_combination <- function(
  threshold_matrix,
  eligible_features,
  ones,
  current_combination,
  check,
  taken_features) {
  num_remaining_features <- ones - length(current_combination)

  if (num_remaining_features == 0) {
    valid_combination <- is_valid_combination(
      threshold_matrix=threshold_matrix,
      current_combination=current_combination,
      ones=ones,
      check=check,
      taken_features=taken_features
    )
    is_valid <- valid_combination$is_valid

    if (check_cols(check=check)) {
      is_valid <- is_valid[1] & is_valid[2]
      if (is_valid) {
        result <- list(combination=current_combination, is_valid=is_valid,
          ev_influenced=valid_combination$ev_influenced)
        return(result)
      }
    } else {
      if (is_valid[1]) {
        result <- list(combination=current_combination, is_valid=is_valid[2],
          ev_influenced=valid_combination$ev_influenced)
        return(result)
      }
    }

    return(FALSE)
  } else {
    while(
      length(eligible_features) > 0 &&
      length(eligible_features) >= num_remaining_features
    ) {
      current_combination <- c(current_combination, eligible_features[1])
      eligible_features <- eligible_features[-1]

      result <- find_combination(
        threshold_matrix=threshold_matrix,
        eligible_features=eligible_features,
        ones=ones,
        current_combination=current_combination,
        check=check,
        taken_features=taken_features
      )

      if (!is.atomic(result)) {
        return(result)
      } else {
        current_combination <- current_combination[1:
          (length(current_combination) - 1)
        ]
      }
    }
    return(FALSE)
  }
}

get_eligible_features <- function(zero_counts, zeros, untaken_features) {
    eligible <- which(zero_counts >= zeros)
    eligible <- intersect(eligible, untaken_features)
    eligible <- as.vector(eligible, mode="integer")
    return(eligible)
}

is_valid_combination <- function(
  threshold_matrix,
  current_combination,
  ones,
  check,
  taken_features) {
  # check if rows are valid
  rows <- threshold_matrix[current_combination, ]
  if (length(current_combination) > 1) {
    rows <- colSums(rows)
  }
  ev_influenced <- which(rows >= 1)
  row_valid <- length(ev_influenced) == ones

  # check if columns are valid
  col_valid <- TRUE
  if(check_cols(check=check)) {
    cols <- t(threshold_matrix)[ev_influenced, ]
    if (length(ev_influenced) > 1) {
      cols <- colSums(cols)
    }
    col_valid <- length(which(cols >= 1)) == ones
  } else {
    if (length(taken_features) > 0) {
      cols <- t(threshold_matrix)[ev_influenced, taken_features]
      if (length(ev_influenced) > 1 && length(taken_features) > 1) {
        cols <- colSums(cols)
      }
      col_valid <- length(which(cols >= 1)) <= ones
    }
  }

  return(list(is_valid=c(row_valid, col_valid), ev_influenced=ev_influenced))
}

check_cols <- function(check) {
  result <- switch(
    tolower(check),
    "rnc"=TRUE,
    "rows"=FALSE,
    err_wrong_check(check=check)
  )

  return(result)
}

err_wrong_check <- function(check) {
  stop(
    paste(
      "'", check, "'", " is not a valid value for check.",
      sep=""
    )
  )
}
