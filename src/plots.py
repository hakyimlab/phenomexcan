import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns


def scatterplot(df, col1, col2, xlabel=None, ylabel=None, title='', dpi=200, sample=None, add_identity_line=True, **kwargs):
    if sample is not None:
        df = df.sample(sample)

    xlabel = col1 if xlabel is None else xlabel
    ylabel = col2 if ylabel is None else ylabel
        
    plt.figure(dpi=dpi)
    ax = sns.scatterplot(data=df, x=col1, y=col2, **kwargs)
    ax.set(
        title=title,
        xlabel=xlabel,
        ylabel=ylabel,
    )
    sns.despine()
    
    if add_identity_line:
        min_val = min((min(df[col1]), min(df[col2])))
        max_val = max((max(df[col1]), max(df[col2])))
        ax.plot([min_val, max_val], [min_val, max_val], 'k', linewidth=0.5)
    
    #ax.set_aspect('equal')
    
    return ax


def qqplot(df, col1, col2, xlabel=None, ylabel=None, title='', dpi=200, sample=None, **kwargs):
    df = df.loc[:, [col1, col2]]
    df[col1] = np.sort(df[col1].values)
    df[col2] = np.sort(df[col2].values)
    
#     xlabel = col1 if xlabel is None else xlabel
#     ylabel = col2 if ylabel is None else ylabel
    
    return scatterplot(df, col1, col2, xlabel, ylabel, title, dpi, sample, **kwargs)
