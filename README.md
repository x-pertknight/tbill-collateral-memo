# TBILL as collateral on Morpho

Analysis of whether OpenEden's TBILL token would pass as collateral in a Morpho market, built from public chain data and the issuer's documents.

- `post.md`: the short public post; `post_comment.md` is its first comment.
- `article.md`: the article, with charts in `charts/`.
- `memo.md`: the technical memo with every number, caveat and the gate. `SCORECARD.md` scores the predictions in `PREDICTIONS.md` and `PREDICTIONS_ADDENDUM.md`.
- `data/raw/`: saved chain and API readings. Individual addresses are replaced by ids.

Rebuild every number, the memo, the article and the post offline from the saved data, and compare them with the committed files (exit status 1 on any difference; nothing is written):

    python3 scripts/build_all.py

To overwrite the generated files with the rebuild instead:

    python3 scripts/build_all.py --write

`scripts/fetch_*.py` re-read the data from the network (read-only calls). `scripts/make_summary.py` and `scripts/make_charts.py` draw the images and need Chrome and matplotlib.

## License

Code is MIT licensed. Text and data are CC BY 4.0.
