package org.sculptor.framework.domain.expression.fts;

public class HighlightOptions {
	int maxWords = -1;
	int minWords = -1;
	int shortWord = -1;
	boolean highlightAll = false;
	int maxFragments = -1;
	String startMark;
	String stopMark;
	String delimiter;

	private HighlightOptions() {};

	public HighlightOptions(int minWords, int maxWords, int shortWord
			, int maxFragments, String startMark, String stopMark, String delimiter) {
		this.highlightAll = false;

		this.minWords = minWords;
		this.maxWords = maxWords;
		this.shortWord = shortWord;
		this.maxFragments = maxFragments;
		this.startMark = startMark;
		this.stopMark = stopMark;
		this.delimiter = delimiter;
	}

	public HighlightOptions(int maxFragments, String startMark, String stopMark, String delimiter) {
		this.highlightAll = true;

		this.maxFragments = maxFragments;
		this.startMark = startMark;
		this.stopMark = stopMark;
		this.delimiter = delimiter;
	}

	public static HighlightOptions builder() {
		return new HighlightOptions();
	}

	public HighlightOptions withMaxWords(int maxWords) {
		this.maxWords = maxWords;
		return this;
	}

	public HighlightOptions withMinWords(int minWords) {
		this.minWords = minWords;
		return this;
	}

	public HighlightOptions withShortWord(int shortWord) {
		this.shortWord = shortWord;
		return this;
	}

	public HighlightOptions withHighlightAll() {
		this.highlightAll = true;
		return this;
	}

	public HighlightOptions withNoHighlightAll() {
		this.highlightAll = false;
		return this;
	}

	public HighlightOptions withMaxFragments(int maxFragments) {
		this.maxFragments = maxFragments;
		return this;
	}

	public HighlightOptions withStartMark(String startMark) {
		this.startMark = startMark;
		return this;
	}

	public HighlightOptions withStopMark(String stopMark) {
		this.stopMark = stopMark;
		return this;
	}

	public HighlightOptions withDelimiter(String delimiter) {
		this.delimiter = delimiter;
		return this;
	}

	public String toSpecString() {
		StringBuilder spec = new StringBuilder();
		if (minWords != -1) {
			spec.append("MinWords=").append(minWords).append(", ");
		}
		if (maxWords != -1) {
			spec.append("MaxWords=").append(maxWords).append(", ");
		}
		if (shortWord != -1) {
			spec.append("ShortWord=").append(shortWord).append(", ");
		}
		if (highlightAll) {
			spec.append("HighlightAll=true").append(", ");
		}
		if (maxFragments != -1) {
			spec.append("MaxFragments=").append(maxFragments).append(", ");
		}
		if (startMark != null) {
			spec.append("StartSel=").append(startMark).append(", ");
		}
		if (stopMark != null) {
			spec.append("StopSel=").append(stopMark).append(", ");
		}
		if (delimiter != null) {
			spec.append("FragmentDelimiter=").append(delimiter).append(", ");
		}

		return spec.length() > 0
				? spec.substring(0, spec.length() - 2)
				: "";
	}
}
