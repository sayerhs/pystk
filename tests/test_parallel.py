# -*- coding: utf-8 -*-

import pytest

def test_parallel(parallel):
    """Run test on non-mpi situations"""
    assert parallel.size == 1
    assert parallel.rank == 0
