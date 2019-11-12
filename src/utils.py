import re
import pickle
import logging


LOG_FORMAT = "[%(filename)s - %(asctime)s] %(levelname)s: %(message)s"


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


def is_number(s):
    try:
        float(s)
        return True
    except ValueError:
        return False
