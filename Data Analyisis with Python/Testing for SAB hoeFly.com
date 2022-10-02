import codecademylib3
import pandas as pd

ad_clicks = pd.read_csv('ad_clicks.csv')
#print(ad_clicks.head())

#print(ad_clicks.groupby('utm_source').user_id.count().reset_index())

ad_clicks['is_click'] = ad_clicks.ad_click_timestamp.notnull()
#print(ad_clicks.head())

clicks_by_source = ad_clicks.groupby(['utm_source','is_click']).user_id.count().reset_index()
clicks_pivot = clicks_by_source.pivot(
  columns = 'is_click',
  index = 'utm_source',
  values = 'user_id'
).reset_index()
#print(clicks_pivot)

clicks_pivot['percent_clicked'] = ((clicks_pivot[True])/(clicks_pivot[False] + clicks_pivot[True]))
#print(clicks_pivot)

#print(ad_clicks.groupby('experimental_group').user_id.count().reset_index())
asd = ad_clicks.groupby(['experimental_group','is_click']).user_id.count().reset_index()
#print(asd)
pivot_asd = asd.pivot(
  columns = 'is_click',
  index = 'experimental_group',
  values = 'user_id'
).reset_index()
pivot_asd['percent_clicked'] = ((pivot_asd[True])/(pivot_asd[False] + pivot_asd[True]))
#print(pivot_asd)
a_clicks = ad_clicks[ad_clicks.experimental_group == 'A']
b_clicks = ad_clicks[ad_clicks.experimental_group == 'B']
a_click_asd = a_clicks.groupby(['is_click','day']).user_id.count().reset_index()
a_click_asd_pivot = a_click_asd.pivot(
  columns = 'is_click',
  index = 'day',
  values = 'user_id'
)
a_click_asd_pivot['percentage'] = a_click_asd_pivot[True]/(a_click_asd_pivot[True]+a_click_asd_pivot[False])
print(a_click_asd_pivot)
b_click_asd = b_clicks.groupby(['is_click','day']).user_id.count().reset_index()
b_click_asd_pivot = b_click_asd.pivot(
  columns = 'is_click',
  index = 'day',
  values = 'user_id'
)
b_click_asd_pivot['percentage'] = b_click_asd_pivot[True]/(b_click_asd_pivot[True]+b_click_asd_pivot[False])
print(b_click_asd_pivot)
