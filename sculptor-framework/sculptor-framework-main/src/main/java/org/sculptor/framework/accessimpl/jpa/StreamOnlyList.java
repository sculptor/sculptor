package org.sculptor.framework.accessimpl.jpa;

import java.util.Collection;
import java.util.Iterator;
import java.util.List;
import java.util.ListIterator;
import java.util.stream.Stream;

public class StreamOnlyList<R> implements List<R> {
	Stream<R> stream;

	public StreamOnlyList(Stream<R> stream) {
		this.stream = stream;
	}

	@Override
	public Stream<R> stream() {
		return stream;
	}

	@Override
	public int size() {
		throw new UnsupportedOperationException("Method size() not supported for scroll-eable result");
	}

	@Override
	public boolean isEmpty() {
		throw new UnsupportedOperationException("Method isEmpty() not supported for scroll-eable result");
	}

	@Override
	public boolean contains(Object o) {
		throw new UnsupportedOperationException("Method contains() not supported for scroll-eable result");
	}

	@Override
	public Iterator<R> iterator() {
		return stream.iterator();
	}

	@Override
	public Object[] toArray() {
		throw new UnsupportedOperationException("Method toArray() not supported for scroll-eable result");
	}

	@Override
	public <T> T[] toArray(T[] a) {
		throw new UnsupportedOperationException("Method toArray() not supported for scroll-eable result");
	}

	@Override
	public boolean add(R e) {
		throw new UnsupportedOperationException("Method add() not supported for scroll-eable result");
	}

	@Override
	public boolean remove(Object o) {
		throw new UnsupportedOperationException("Method remove() not supported for scroll-eable result");
	}

	@Override
	public boolean containsAll(Collection<?> c) {
		throw new UnsupportedOperationException("Method containsAll() not supported for scroll-eable result");
	}

	@Override
	public boolean addAll(Collection<? extends R> c) {
		throw new UnsupportedOperationException("Method addAll() not supported for scroll-eable result");
	}

	@Override
	public boolean addAll(int index, Collection<? extends R> c) {
		throw new UnsupportedOperationException("Method addAll() not supported for scroll-eable result");
	}

	@Override
	public boolean removeAll(Collection<?> c) {
		throw new UnsupportedOperationException("Method removeAll() not supported for scroll-eable result");
	}

	@Override
	public boolean retainAll(Collection<?> c) {
		throw new UnsupportedOperationException("Method retainAll() not supported for scroll-eable result");
	}

	@Override
	public void clear() {
		throw new UnsupportedOperationException("Method clear() not supported for scroll-eable result");
	}

	@Override
	public R get(int index) {
		throw new UnsupportedOperationException("Method get() not supported for scroll-eable result");
	}

	@Override
	public R set(int index, R element) {
		throw new UnsupportedOperationException("Method set() not supported for scroll-eable result");
	}

	@Override
	public void add(int index, R element) {
		throw new UnsupportedOperationException("Method add() not supported for scroll-eable result");
	}

	@Override
	public R remove(int index) {
		throw new UnsupportedOperationException("Method remove() not supported for scroll-eable result");
	}

	@Override
	public int indexOf(Object o) {
		throw new UnsupportedOperationException("Method indexOf() not supported for scroll-eable result");
	}

	@Override
	public int lastIndexOf(Object o) {
		throw new UnsupportedOperationException("Method lastIndexOf() not supported for scroll-eable result");
	}

	@Override
	public ListIterator<R> listIterator() {
		throw new UnsupportedOperationException("Method listIterator() not supported for scroll-eable result");
	}

	@Override
	public ListIterator<R> listIterator(int index) {
		throw new UnsupportedOperationException("Method listIterator() not supported for scroll-eable result");
	}

	@Override
	public List<R> subList(int fromIndex, int toIndex) {
		throw new UnsupportedOperationException("Method listIterator() not supported for scroll-eable result");
	}

}
