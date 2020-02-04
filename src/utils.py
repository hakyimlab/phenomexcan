import re
import pickle
import logging
from subprocess import run


LOG_FORMAT = "[%(filename)s - %(asctime)s] %(levelname)s: %(message)s"
HDF5_KEY_NO_PATTERN = re.compile('[^0-9a-zA-Z_]')


def get_logger(filename=None):
    formatter = logging.Formatter(LOG_FORMAT)

    logger = logging.getLogger('root')
    logger.setLevel(logging.DEBUG)

    ch = logging.StreamHandler()
    ch.setLevel(logging.INFO)
    ch.setFormatter(formatter)
    logger.addHandler(ch)

    if filename is not None:
        fh = logging.FileHandler(filename)
        fh.setLevel(logging.DEBUG)
        fh.setFormatter(formatter)
        logger.addHandler(fh)

    return logger



def load_pickle(filepath):
    with open(filepath, 'rb') as f:
        return pickle.load(f)


def chunker(seq, size):
    """
    Divides a sequence in chunks according to the given size.
    :param seq:
    :param size:
    :return:
    """
    return (seq[pos:pos + size] for pos in range(0, len(seq), size))


def simplify_string(s):
    # Remove all non-word characters (everything except numbers and letters)
    s = re.sub(r"[^\w\s]", '', s)

    # Replace all runs of whitespace with a single dash
    s = re.sub(r"\s+", '_', s)

    return s


def simplify_string_for_hdf5(pheno_full_code):
    clean_col = re.sub(HDF5_KEY_NO_PATTERN, '_', pheno_full_code)
    return 'c' + clean_col


def is_number(s):
    try:
        float(s)
        return True
    except ValueError:
        return False


def run_command(command, raise_on_error=True):
    r = run(command, shell=True)

    if raise_on_error and r.returncode != 0:
        raise Exception(f'Command "{command}" failed with code {r.returncode}')

    return r
