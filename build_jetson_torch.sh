git clone https://github.com/pytorch/pytorch.git
pushd pytorch

git fetch --tags --prune
git checkout v2.8.0
git submodule update --init --recursive --depth=1


virtualenv .venv
source .venv/bin/activate
pip install -r requirements.txt

export USE_CUDNN=1
export USE_CUSPARSELT=1
export USE_CUDSS=1
export USE_CUFILE=1
export USE_NATIVE_ARCH=0 # This crash due instructions not supported SVE128 https://github.com/pytorch/pytorch/pull/160328
export USE_DISTRIBUTED=1
export USE_FLASH_ATTENTION=0
export USE_MEM_EFF_ATTENTION=0
export USE_TENSORRT=0
export USE_PRIORITIZED_TEXT_FOR_LD=1
export USE_BLAS=1
export USE_NCCL=0
export MAX_JOBS=4
export BUILD_TESTS=0

CMAKE_CUDA_COMPILER=/usr/local/cuda/bin/nvcc python setup.py bdist_wheel
popd

