$oldbk = Import-Excel -Path '\\hcohesity05\cohesity_reports\2022\7\07-29\Cohesity_FETB_Report-2022-07-29-14-26-48.xlsx'
#$newbk = Import-Excel -Path '\\hcohesity05\cohesity_reports\2022\8\08-26\Cohesity_FETB_Report-2022-08-26-14-26-48.xlsx'


Import-Excel -Path '\\hcohesity05\cohesity_reports\2022\8\08-26\Cohesity_FETB_Report-2022-08-26-14-26-48.xlsx' | Where-Object {
    $_."Server Name" -notin $oldbk."Server Name"
} | Export-Excel -Path '.\diff.xlsx'

#$Compare = Compare-Object $oldbk $newbk -Property "Server Name"  -PassThru 
        #$Compare | Export-Excel -Path '.\diff.xlsx'