# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True
# cython: infer_types = True
# cython: boundscheck = False
# cython: wraparound = False

cimport cython
cimport numpy as np

from cpython.mem cimport PyMem_Malloc, PyMem_Realloc, PyMem_Free
from cpython.string cimport PyString_AsString

import sys
import numpy as np

cdef class Parallel:
    """Interface to STK MPI

    TODO: Enable linking with mpi4py
    """

    def __eq__(self, Parallel other):
        return self.comm == other.comm

    @staticmethod
    def initialize(arg_list=None):
        """Initialize the MPI object"""
        tmp = arg_list or sys.argv
        argv = [ss.encode('UTF-8') for ss in tmp]
        cdef int nargs = len(argv)
        cdef char** cargv = <char**> PyMem_Malloc(nargs * sizeof(char*));
        if not cargv:
            raise MemoryError()

        cdef Parallel self = Parallel.__new__(Parallel)
        try:
            for i in range(nargs):
                cargv[i] = argv[i]
            self.comm = parallel_machine_init(&nargs, &cargv);
            self.rank = parallel_machine_rank(self.comm);
            self.size = parallel_machine_size(self.comm);
        finally:
            PyMem_Free(cargv)

        return self

    def finalize(self):
        """Call MPI finalize"""
        parallel_machine_finalize()

    cdef parallel_reduce(self, cython.numeric [:] inp, optype="sum"):
        """Perform a parallel sum reduction operation and return the global sum"""
        num_vals = inp.shape[0]
        if cython.numeric is int:
            dtype = np.intc
        elif cython.numeric is long:
            dtype = np.long
        elif cython.numeric is cython.longlong:
            dtype = np.longlong
        elif cython.numeric is cython.float:
            dtype = np.float
        else:
            dtype = np.double

        retval = np.zeros((num_vals, ), dtype=dtype)
        cdef cython.numeric[:] ret_view = retval
        if optype == "sum":
            all_reduce_sum(self.comm, &inp[0], &ret_view[0], num_vals)
        elif optype == "max":
            all_reduce_max(self.comm, &inp[0], &ret_view[0], num_vals)
        elif optype == "min":
            all_reduce_min(self.comm, &inp[0], &ret_view[0], num_vals)
        else:
            raise NotImplementedError("Invalid operation type passed: " + optype)
        return retval

    def parallel_reduce_sum(self, cython.numeric [:] inp):
        """Wrapper to stk::parallel_reduce_sum"""
        return self.parallel_reduce(inp, "sum")

    def parallel_reduce_max(self, cython.numeric [:] inp):
        """Wrapper to stk::parallel_reduce_max"""
        return self.parallel_reduce(inp, "max")

    def parallel_reduce_min(self, cython.numeric [:] inp):
        """Wrapper to stk::parallel_reduce_min"""
        return self.parallel_reduce(inp, "min")
