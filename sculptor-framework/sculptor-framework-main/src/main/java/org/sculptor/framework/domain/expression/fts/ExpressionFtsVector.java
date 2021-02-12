package org.sculptor.framework.domain.expression.fts;

import org.sculptor.framework.domain.expression.Expression;
import org.sculptor.framework.domain.expression.ExpressionNumeric;

public interface ExpressionFtsVector<T> extends Expression<T> {
	// ignores the document length
	public int NORM_DEFAULT = 0;
	public int NORM_LENGTH_IGNORE = 0;

	// divides the rank by 1 + the logarithm of the document length
	public int NORM_LENGTH_LOG = 1;

	// divides the rank by the document length
	public int NORM_LENGTH = 2;

	// divides the rank by the mean harmonic distance between extents (this is implemented only by ts_rank_cd)
	public int NORM_MHD = 4;

	// divides the rank by the number of unique words in document
	public int NORM_UNIQUE_WORDS = 8;

	// divides the rank by 1 + the logarithm of the number of unique words in document
	public int NORM_UNIQUE_WORDS_LOG = 16;

	// divides the rank by itself + 1
	public int NORM_ITSELF = 32;

	public String DEFAULT_LANGUAGE = "english";

	// Normal ranking, frequency of their matching lexemes
	ExpressionNumeric<T> ftsRank(ExpressionFtsQuery query);
	ExpressionNumeric<T> ftsRank(ExpressionFtsQuery query, int normalization);
	ExpressionNumeric<T> ftsRank(ExpressionFtsQuery query, float weightA, float weightB, float weightC, float weightD);
	ExpressionNumeric<T> ftsRank(ExpressionFtsQuery query, float weightA, float weightB, float weightC, float weightD, int normalization);

	// Cover density ranking, don't use with stripped vector
	ExpressionNumeric<T> ftsRankCd(ExpressionFtsQuery query);
	ExpressionNumeric<T> ftsRankCd(ExpressionFtsQuery query, int normalization);
	ExpressionNumeric<T> ftsRankCd(ExpressionFtsQuery query, float weightA, float weightB, float weightC, float weightD);
	ExpressionNumeric<T> ftsRankCd(ExpressionFtsQuery query, float weightA, float weightB, float weightC, float weightD, int normalization);

	ExpressionFtsVector<T> ftsStrip();
	ExpressionNumeric<T> ftsLength();
	ExpressionFtsVector<T> ftsSetWeightA();
	ExpressionFtsVector<T> ftsSetWeightB();
	ExpressionFtsVector<T> ftsSetWeightC();
	ExpressionFtsVector<T> ftsSetWeightD();
	ExpressionFtsVector<T> ftsConcat(ExpressionFtsVector<T> other);
}
