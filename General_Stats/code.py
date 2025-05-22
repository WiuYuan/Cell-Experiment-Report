import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from scipy.stats import ttest_ind

def add_stat_annotation(ax, x1, x2, y, h, text):
    ax.plot([x1, x1, x2, x2], [y, y+h, y+h, y], lw=1.5, c='k')
    ax.text((x1+x2)*0.5, y+h*1.1, text, ha='center', va='bottom', color='k', fontsize=14)

def violin_with_mean_sem_and_significance_lr(data, x, y, ylabel, hue, title, title_df):
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 6))  # 1行2列

    # 左边：violin + mean+sem + 显著性
    sns.violinplot(data=data, x=x, y=y, hue=hue, split=True, inner=None, palette='Set2', ax=ax1)
    sns.pointplot(data=data, x=x, y=y, hue=hue, dodge=0.4, join=False,
                  palette='dark', markers='o', ci='sd', ax=ax1, errwidth=1.5, capsize=0.1)

    x_categories = sorted(data[x].unique())
    hue_categories = data[hue].unique()
    y_max = data[y].max()

    for i, day in enumerate(x_categories):
        group1 = data[(data[x] == day) & (data[hue] == hue_categories[0])][y]
        group2 = data[(data[x] == day) & (data[hue] == hue_categories[1])][y]

        if len(group1) > 1 and len(group2) > 1:
            stat, p = ttest_ind(group1, group2, equal_var=False)
            if p < 0.001:
                sig = '***'
            elif p < 0.01:
                sig = '**'
            elif p < 0.05:
                sig = '*'
            else:
                sig = 'ns'

            y_pos = y_max * 1.05
            x1 = i - 0.2
            x2 = i + 0.2
            add_stat_annotation(ax1, x1, x2, y_pos, y_max * 0.03, sig)

    ax1.set_title(title)
    ax1.legend_.remove()
    ax1.set_xlabel('Day')
    ax1.set_ylabel(ylabel)

    # 右边：KDE 分布对比
    for group in hue_categories:
        subset = data[data[hue] == group]
        for day in x_categories:
            sns.kdeplot(subset[subset[x] == day][y], label=f'{group}-{day}', ax=ax2, fill=True, alpha=0.3)

    ax2.set_title(title_df)
    ax2.set_xlabel(ylabel)
    ax2.set_ylabel('Density')
    ax2.legend(title=hue + ' - Day', bbox_to_anchor=(1.05, 1), loc='upper left')

    plt.tight_layout()
    plt.show()


# 面积 > 1000
df = pd.read_csv("uv_area_summary.tsv", sep='\t')

def parse_info(filename):
    if "mca" in filename:
        group = "mca"
    elif "wt" in filename:
        group = "wt"
    else:
        group = "unknown"
    m = re.search(r'(\d)d', filename)
    day = m.group(1) + "d" if m else "unknown"
    return pd.Series([group, day])

df[['Group', 'Day']] = df['Filename'].apply(parse_info)
df['Ratio_>1500_to_>1000'] = df['Area_>1500(um2)'] / df['Area_>1000(um2)']

sns.set(style="whitegrid")
df['Ratio_1500_1000'] = df['Area_>1500(um2)'] / df['Area_>1000(um2)']
violin_with_mean_sem_and_significance_lr(
    data=df,
    x='Day',
    y='Area_>1000(um2)',
    ylabel='Area ($\mu\mathrm{m}^2$)',
    hue='Group',
    title='Violin Plot for Actual Area of Leaf Cells (µm^2)',
    title_df='Density Plot for Actual Area of Leaf Cells'
)

# 面积 > 1500
violin_with_mean_sem_and_significance_lr(
    data=df,
    x='Day',
    y='Area_>1500(um2)',
    ylabel='Area ($\mu\mathrm{m}^2$)',
    hue='Group',
    title='Violin Plot for Actual Area of Vessel Cells',
    title_df='Density Plot for Actual Area of Vessel Cells'
)

# 比例：>1500 / >1000
violin_with_mean_sem_and_significance_lr(
    data=df,
    x='Day',
    y='Ratio_1500_1000',
    ylabel='Ratio',
    hue='Group',
    title='Violin Plot for Ratio of Vessel Cell Area to Leaf Cell Area',
    title_df='Density Plot for Ratio of Vessel Cell Area to Leaf Cell Area'
)
