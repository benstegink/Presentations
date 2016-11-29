Enable-SPWebTemplateForSiteMaster -Template STS#0
New-SPSiteMaster -ContentDatabase SP2016_Content_SP16-Intranet -Template STS#0
New-SPSite -Url http://sp16-intranet/sites/fastsite1 -Template STS#0 -CreateFromSiteMaster -OwnerAlias navuba\spadmin -SecondaryOwnerAlias navuba\ben