import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

pd.set_option("display.max_columns", 12)
pd.set_option("display.min_rows", 6)
pd.set_option("display.width", 1800)


def drop_stores_that_dont_have_data_for_both_times(df) -> pd.DataFrame():
    complete_stores = df.store[df.store.duplicated(keep=False)]
    return df[df.store.isin(complete_stores)]


def return_diff_column_for_one_column(df, col) -> []:
    new_col = []
    for store in df.store.unique():
        for row in df[(df.store == store)].itertuples():
            try:
                if row.time == 0:
                    new_col.append(None)
                if row.time == 1:
                    new_col.append((df[(df.store == store) & (df.time == 1)][col].values[0] -
                                    df[(df.store == store) & (df.time == 0)][col].values[0]))
            except:
                pass
    return new_col


def return_df_with_fte_data_for_both_times(df) -> pd.DataFrame():
    new_df = pd.DataFrame([])
    for store in df.store.unique():
        try:
            if len(df[(df.store == store)][['empft', 'emppt']].dropna()) == 2:
                new_df = pd.concat([new_df, df[(df.store == store)]])
        except:
            pass

    return new_df


def return_avg_in_table_order(df, time) -> []:
    row = [df[(df['time'] == time) & (df['state'] == 0)]['fte'].mean(),
           df[(df['time'] == time) & (df['state'] == 1)]['fte'].mean(),
           df[(df['time'] == time) & (df['state'] == 1)]['fte'].mean() -
           df[(df['time'] == time) & (df['state'] == 0)]['fte'].mean(),
           df[(df['time'] == time) & (df['state'] == 0) & (df['wage_st'] == 4.25)]['fte'].mean(),
           df[(df['time'] == time) & (df['state'] == 0) & (4.25 < df['wage_st']) & (df['wage_st'] < 5)][
               'fte'].mean(),
           df[(df['time'] == time) & (df['state'] == 0) & (df['wage_st'] >= 5)]['fte'].mean(),
           df[(df['time'] == time) & (df['state'] == 0) & (df['wage_st'] == 4.25)]['fte'].mean()
           - df[(df['time'] == time) & (df['state'] == 0) & (df['wage_st'] >= 5)]['fte'].mean(),
           df[(df['time'] == time) & (df['state'] == 0) & (4.25 < df['wage_st']) & (df['wage_st'] < 5)][
               'fte'].mean()
           - df[(df['time'] == time) & (df['state'] == 0) & (df['wage_st'] >= 5)]['fte'].mean(),
           ]
    return np.around(row, 2)


def return_sem_in_table_order(df, time) -> []:
    row = [df[(df['time'] == time) & (df['state'] == 0)]['fte'].sem(),
           df[(df['time'] == time) & (df['state'] == 1)]['fte'].sem(),
           df[(df['time'] == time) & (df['state'] == 1)]['fte'].sem() -
           df[(df['time'] == time) & (df['state'] == 0)]['fte'].sem(),
           df[(df['time'] == time) & (df['state'] == 0) & (df['wage_st'] == 4.25)]['fte'].sem(),
           df[(df['time'] == time) & (df['state'] == 0) & (4.25 < df['wage_st']) & (df['wage_st'] < 5)][
               'fte'].sem(),
           df[(df['time'] == time) & (df['state'] == 0) & (df['wage_st'] >= 5)]['fte'].sem(),
           df[(df['time'] == time) & (df['state'] == 0) & (df['wage_st'] == 4.25)]['fte'].sem()
           - df[(df['time'] == time) & (df['state'] == 0) & (df['wage_st'] >= 5)]['fte'].sem(),
           df[(df['time'] == time) & (df['state'] == 0) & (4.25 < df['wage_st']) & (df['wage_st'] < 5)][
               'fte'].sem()
           - df[(df['time'] == time) & (df['state'] == 0) & (df['wage_st'] >= 5)]['fte'].sem(),
           ]
    row_as_strings = []
    for w in row:
        row_as_strings.append('(' + str(abs(round(w, 2))) + ')')
    return row_as_strings


def return_change_of_fte_in_table_order(df) -> []:
    row = [df[(df['state'] == 0)]['change_fte'].mean(),
           df[(df['state'] == 1)]['change_fte'].mean(),
           df[(df['state'] == 1)]['change_fte'].mean() -
           df[(df['state'] == 0)]['change_fte'].mean(),
           df[(df['state'] == 0) & (df['wage_st'] == 4.25)]['change_fte'].mean(),
           df[(df['state'] == 0) & (4.25 < df['wage_st']) & (df['wage_st'] < 5)][
               'change_fte'].mean(),
           df[(df['state'] == 0) & (df['wage_st'] >= 5)]['change_fte'].mean(),
           df[(df['state'] == 0) & (df['wage_st'] == 4.25)]['change_fte'].mean()
           - df[(df['state'] == 0) & (df['wage_st'] >= 5)]['change_fte'].mean(),
           df[(df['state'] == 0) & (4.25 < df['wage_st']) & (df['wage_st'] < 5)][
               'change_fte'].mean()
           - df[(df['state'] == 0) & (df['wage_st'] >= 5)]['change_fte'].mean(),
           ]
    return np.around(row, 2)


def return_change_of_sem_in_table_order(df) -> []:
    row = [df[(df['state'] == 0)]['change_fte'].sem(),
           df[(df['state'] == 1)]['change_fte'].sem(),
           df[(df['state'] == 1)]['change_fte'].sem() -
           df[(df['state'] == 0)]['change_fte'].sem(),
           df[(df['state'] == 0) & (df['wage_st'] == 4.25)]['change_fte'].sem(),
           df[(df['state'] == 0) & (4.25 < df['wage_st']) & (df['wage_st'] < 5)][
               'change_fte'].sem(),
           df[(df['state'] == 0) & (df['wage_st'] >= 5)]['change_fte'].sem(),
           df[(df['state'] == 0) & (df['wage_st'] == 4.25)]['change_fte'].sem()
           - df[(df['state'] == 0) & (df['wage_st'] >= 5)]['change_fte'].sem(),
           df[(df['state'] == 0) & (4.25 < df['wage_st']) & (df['wage_st'] < 5)][
               'change_fte'].sem()
           - df[(df['state'] == 0) & (df['wage_st'] >= 5)]['change_fte'].sem(),
           ]
    row_as_strings = []
    for w in row:
        row_as_strings.append('(' + str(abs(round(w, 2))) + ')')
    return row_as_strings


if __name__ == '__main__':
    ### import data
    path_and_file_name = "C:/Users/reifv/root/Heidelberg Master/impact_eval/Impact_Eval/PS3_Viktor_Reif/" \
                         "cardkrueger94.dta"
    data = pd.read_stata(path_and_file_name)

    ### excerise 9: create table 3 p 780
    data = data.sort_values(by=['store'])
    data['fte'] = data['empft'] + 0.5 * data['emppt']
    data["change_fte"] = return_diff_column_for_one_column(data, 'fte')
    table = pd.DataFrame(
        ['Stores by state', ' ', ' ', 'Stores in New Jersey', ' ', ' ', 'Differences within New Jersey', ' ', ])
    table.columns = [' ']
    table['  '] = [' ', ' ', 'Difference,', 'Wage =', 'Wage =', 'Wage >', 'Low-', 'Midrange-']
    table['   '] = ['PA', 'NJ', 'NJ-PA', '$4.25', '$4.26-$4.99', '$5', 'high', 'high']
    table['Variable'] = ['(i)', '(ii)', '(iii)', '(iv)', '(v)', '(vi)', '(vii)', '(viii)']
    table['1. FTE employment before,'] = return_avg_in_table_order(data.dropna(subset=['nregisters11']), 0)
    table['all available observations'] = return_sem_in_table_order(data.dropna(subset=['nregisters11']), 0)
    table['2. FTE employment after,'] = return_avg_in_table_order(data.dropna(subset=['nregisters11']), 1)
    table['all available observations '] = return_sem_in_table_order(data.dropna(subset=['nregisters11']), 1)
    table['3. Change in mean FTE'] = return_change_of_fte_in_table_order(data.dropna(subset=['nregisters11']))
    table['employment'] = return_change_of_sem_in_table_order(data.dropna(subset=['nregisters11']))
    table['4. Change in mean FTE'] = return_change_of_fte_in_table_order(return_df_with_fte_data_for_both_times(data))
    table['employment, balanced'] = return_change_of_sem_in_table_order(
        return_df_with_fte_data_for_both_times(data))
    table['sample of stores'] = [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ']
    table['5. Change in mean FTE'] = return_change_of_fte_in_table_order(data[data['open'] != 0])
    table['employment, setting'] = return_change_of_sem_in_table_order(data[data['open'] != 0])
    table['FTE at temporarily'] = [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ']
    table['closed stores to 0'] = [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ']
    table = table.T
    # print(table)
    raw_latex = table.style.to_latex(sparse_columns=False)
    filename = 'table3'
    with open(filename + '.txt', 'a') as file:
        file.write(raw_latex)

    ### excercise 5: recreate figure 1
    print(data)
    fig, axes = plt.subplots(nrows=2, ncols=1, figsize=(8, 4))
    data.hist(ax=axes[0], bins=12, column=['wage_st'])
    # axes[0].hist(data[data['state'] == 0]['wage_st'])
    # axes[0].hist(data[data['state'] == 1]['wage_st'])
    # axes[1].hist(data['wage_st'])
    fig.tight_layout()
    fig.savefig('double_plot_year_dist_with_and_whithout_co.png')
    plt.show()
    plt.clf()
