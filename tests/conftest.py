# -*- coding: utf-8 -*-

import pytest
from stk.api.util.parallel import Parallel

@pytest.fixture(scope='session')
def parallel():
    arg_list=["ptest"]
    par = Parallel.initialize(arg_list)
    yield par
    par.finalize()
