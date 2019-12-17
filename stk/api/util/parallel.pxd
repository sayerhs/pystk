# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

cimport cython

cdef extern from "mpi.h" nogil:
  ctypedef struct _mpi_comm_t
  ctypedef _mpi_comm_t* MPI_Comm

cdef extern from "stk_util/parallel/Parallel.hpp" namespace "stk" nogil:
  ctypedef MPI_Comm ParallelMachine
  cdef ParallelMachine parallel_machine_init(int* argc, char*** argv)
  cdef void parallel_machine_finalize()
  cdef int parallel_machine_rank(ParallelMachine)
  cdef int parallel_machine_size(ParallelMachine)

cdef extern from "stk_util/parallel/ParallelReduce.hpp" namespace "stk" nogil:
  void all_reduce_max[T](ParallelMachine comm, const T* loc, T* g_val, unsigned count)
  void all_reduce_min[T](ParallelMachine comm, const T* loc, T* g_val, unsigned count)
  void all_reduce_sum[T](ParallelMachine comm, const T* loc, T* g_val, unsigned count)
  T get_global_sum[T](ParallelMachine comm, const T local)

cdef class Parallel:
  cdef MPI_Comm comm
  cdef readonly int rank
  cdef readonly int size

  cdef parallel_reduce(self, cython.numeric [:] inp, optype=*)
