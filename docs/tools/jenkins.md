# jenkins

## Linux Python 环境模板

通过`pyenv`在节点上安装指定版本的 Python 解释器

```Groovy
pipeline {
    agent any
    environment {
        PYTHON_VERSION = '3.12.9'
        PYENV_ROOT = "${env.HOME}/.pyenv"
        PATH = "${PYENV_ROOT}/bin:${PYENV_ROOT}/shims:${env.PATH}"
    }
    stages {
        stage('Install Build Dependencies') {
            steps {
                script {
                    sh """
                    # 更新包列表
                    apt-get update -qq

                    # 安装编译工具链和 Python 编译所需的依赖
                    apt-get install -y -qq \\
                        build-essential \\
                        gcc \\
                        g++ \\
                        make \\
                        libssl-dev \\
                        libbz2-dev \\
                        libreadline-dev \\
                        libsqlite3-dev \\
                        zlib1g-dev \\
                        libffi-dev \\
                        liblzma-dev \\
                        curl \\
                        git
                    """
                }
            }
        }
        stage('Check and Install Pyenv') {
            steps {
                script {
                    sh """
                    if ! command -v pyenv >/dev/null 2>&1; then
                        rm -rf ~/.pyenv
                        curl https://pyenv.run | bash
                    fi
                    """
                }
            }
        }
        stage('Check and Install Python ${env.PYTHON_VERSION} via Pyenv') {
            steps {
                script {
                    sh """
                    eval "\$(pyenv init - sh)"
                    pyenv update || true
                    pyenv install ${env.PYTHON_VERSION} -s -v
                    pyenv rehash
                    """
                }
            }
        }
        stage('Run Tests with Python ${env.PYTHON_VERSION}') {
            steps {
                script {
                    sh """
                    eval "\$(pyenv init - sh)"
                    pyenv local ${env.PYTHON_VERSION}
                    python --version
                    """
                }
            }
        }
    }
}

```
