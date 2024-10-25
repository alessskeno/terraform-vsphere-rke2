username = "administrator@vcsa.vcloud.local"
password = "Aydin98!!@@"

vsphere_server = "vcsa.vcloud.local"

### AZ1
vsphere_datacenter_az1    = "New Datacenter"
vsphere_host_az1          = "10.100.105.100"
vsphere_resource_pool_az1 = "RKE2_AZ1"
vsphere_datastore_az1     = "datastore1"
vsphere_network_name_az1  = "VM Network"
vm_cidr_az1               = "10.100.105.0/24"
vm_gw_ip_az1 = "10.100.105.1"

### AZ3
vsphere_datacenter_az3    = "New Datacenter"
vsphere_host_az3          = "10.100.105.101"
vsphere_resource_pool_az3 = "RKE2_AZ3"
vsphere_datastore_az3     = "datastore1 (1)"
vsphere_network_name_az3  = "VM Network"
vm_cidr_az3               = "10.100.105.0/24"
vm_gw_ip_az3 = "10.100.105.1"

#===========================#

ansible_password = "8597750aA"
rke2_token       = "83005ddb9ce46907f4067eb59f1fa1fac81f7528e382654f4d24612eac28a77c"
hashed_pass      = "$6$TBTp1ZGJ7wABlPbG$vymuon7bGqECHt1WFUFTc9Tz1wvJPD6m0cMdfdXIu5Vh5zvjQcCgqrC0xGTapggIFJeAOvM.xyOWcAlHT2Vri1"

gitlab_gitops_group_token = ""
gitlab_runner_token       = ""
general_password          = "8597750aA"
general_user              = "devops"
basic_auth_pass           = "devops:$6$ICcCh29M20WyDfHf$nQsarjccnyfa/rSktgzWdA/0OaiNtN/lMBd3c1abJBgfQ0wn53jcmKGwaAOrDROTjHcQKVfH/.WGKicwzy5zj/"

domain          = "hostart.az"
domain_crt      = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUV4ekNDQXErZ0F3SUJBZ0lVZlp5UlpqOTBDMldkVytERHBRU0NhcDNnTVJVd0RRWUpLb1pJaHZjTkFRRUwKQlFBd2dZUXhDekFKQmdOVkJBWVRBa0ZhTVFzd0NRWURWUVFJREFKQldqRU5NQXNHQTFVRUJ3d0VRbUZyZFRFVQpNQklHQTFVRUNnd0xTRzl6ZEdGeWRDQk1URU14Q3pBSkJnTlZCQXNNQWtsVU1STXdFUVlEVlFRRERBcG9iM04wCllYSjBMbUY2TVNFd0h3WUpLb1pJaHZjTkFRa0JGaEpoTG10aGJtRnVRR2h2YzNSaGNuUXVZWG93SGhjTk1qUXgKTURFME1UQXdNakl4V2hjTk1qY3dPREEwTVRBd01qSXhXakJiTVJVd0V3WURWUVFEREF3cUxtaHZjM1JoY25RdQpZWG94Q3pBSkJnTlZCQVlUQWtGYU1RMHdDd1lEVlFRSURBUkNZV3QxTVEwd0N3WURWUVFIREFSQ1lXdDFNUmN3CkZRWURWUVFLREE1b2IzTjBZWEowTG1GNklFeE1RekNDQVNJd0RRWUpLb1pJaHZjTkFRRUJCUUFEZ2dFUEFEQ0MKQVFvQ2dnRUJBTUdsVlhiNDJ6ajBXN1gveGszemt3S203QXZUVEkyQjlLMHU1WG10aml3VkxUc3NtYTZpUU41VQpDRkxRU0R2SjM3SERvbytObnRGOC9oYXU0a05JZkJpWnRsU0xpNGxzRUk2VkJRVlJxTklJaWl0SnNGeHFtVzZuCmlHUWVxSzJYWk9VVXRsNldtVFdEbmlwYmRpRFFpYnNGTHI3bEJlR2k2NVBOSlFqbmFhMXBCOUFLZENMSnRKUXAKYWt6WFpoSSt5NUNKSXdoK25GMWtkUGRjU2Z0YW1LZkRvejE0LzB5bmRjWU1Vc1VONTB1a0hNbGNnc0llVkZKRApzNThQOGFnejFuWEY3aEpuUGpUZVdxMll4YmE4RWx6czNNTkNyM3NmSlZFdm1xbGE2WStpb2txSmNob24zWkIwClZlZUFFbUQ4Y0lLRXBVRjkwa3pKdGVjSlZzdllZWUVDQXdFQUFhTlpNRmN3RGdZRFZSMFBBUUgvQkFRREFnV2cKTUNBR0ExVWRKUUVCL3dRV01CUUdDQ3NHQVFVRkJ3TUJCZ2dyQmdFRkJRY0RBakFqQmdOVkhSRUVIREFhZ2dwbwpiM04wWVhKMExtRjZnZ3dxTG1odmMzUmhjblF1WVhvd0RRWUpLb1pJaHZjTkFRRUxCUUFEZ2dJQkFIYUo1ZGl2CnlOdE1RK0tEb2d1L1dpUFhuMll3THpVb2czVHBrNm5NSGhUUGI5WjM2Y3c2bTR3Mk1SY0FqQWU5Y0NoYlN3d2UKY2dsTTJiUDJ4WFZ6cnhpMS9HL0ZxR3Y5NDFuRDFiUWtkb3BoQkRpaHREa09vV0tIcUtjeVcySmVKTnpPY0t1cQpJMDlub09CK3dvc3NTcDYxQ2RHQkZ6YlFVK21XVlhrd1pRYU5Ga0FPMnlRMkFUNk5yNUxKajUwVWYvdExsTlc4Ckh5R2I4cjYwT21Gb2JRTWF6MVlQYjYxTHdpY1hKQnZCcWRDREc3VDRKdnhmV1hZTTIxR2lqbU5yb0dOSFZwWUkKeGVXdHZ2OVRjckcwR1ZzUDdEWDdXcXJJa3dSWU1tZlVPejg0d0NDaElyL3R4T2l2RjVkQ25IVytFYjcxQmVDagpNWDZtSXBXQjRYMjh3MzNkZ2xtZ0V1c05KYi9PMFVvcjFpU1RRRDVyMFNVQTlTUUxUTUVDN2JXOFVPSlVFb3QxClZmSzI1ZndwZWZpRHhock81Q0FxOFBLeDIrT2pzVFcvL3FLU2hvdnpwUVBQdXhEVWp4aHdmNE5kVTRkRmJGV1kKdzhhRXQzTVV4MXp5WWw3ZjVHNi9ubXFjWDY2bWNzdFN1YWxvcW4zakF0bFZuQmVXR0RnTm93Zllvbm5XaVVhZQpyK1U0R21LSkpIZUZteTFFTjk2bzhUME8rL01aV3pValVtTldrRHZvQmZzcW9EeE5HQk1nMjVDenZ2NGtSSVZCCmcwTFdzZVNRUFpSeThMTlN0YXV0elhMY0hBUThmOERmWlhGWkNvbDFnWkNnS2VlNjNXYU1Xb25PbFNzR2tNdXgKcDZQQVpZb0NXQUdDV29wSHhGN0tlZWVjZkhCbkI2c25XTjdvCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K"
domain_key      = "LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFb3dJQkFBS0NBUUVBd2FWVmR2amJPUFJidGYvR1RmT1RBcWJzQzlOTWpZSDByUzdsZWEyT0xCVXRPeXlaCnJxSkEzbFFJVXRCSU84bmZzY09pajQyZTBYeitGcTdpUTBoOEdKbTJWSXVMaVd3UWpwVUZCVkdvMGdpS0swbXcKWEdxWmJxZUlaQjZvclpkazVSUzJYcGFaTllPZUtsdDJJTkNKdXdVdXZ1VUY0YUxyazgwbENPZHByV2tIMEFwMApJc20wbENscVROZG1FajdMa0lrakNINmNYV1IwOTF4SisxcVlwOE9qUFhqL1RLZDF4Z3hTeFEzblM2UWN5VnlDCndoNVVVa096bncveHFEUFdkY1h1RW1jK05ONWFyWmpGdHJ3U1hPemN3MEt2ZXg4bFVTK2FxVnJwajZLaVNvbHkKR2lmZGtIUlY1NEFTWVB4d2dvU2xRWDNTVE1tMTV3bFd5OWhoZ1FJREFRQUJBb0lCQUVPZEdnbFBmU1FXMWtybgpBdlBHMzRibWg3YmRVWFo3Y05aamNJYWEzZkJ3ZUhtWDZoVTYzQkdGSDk3aWtNWW5oNjdIRTJTeVcwamtMc2YyCnlsUVo1QkttNFM0R0IzTzFRdGEyRzZtdXlKYUZtdERnaXU3SjNjYndRa1JMSERSNGp5Y1pvMC9GbjdzNnVLZ3IKaFVTUjYvVmNLdVZHakZZcmo3dnN2a2lzbkk2S2FUbnY0cmFzUDhFNXBnemZCUE1IeiszWGZTTExMWEZEV29hcwpkWXc3cUppQmczbHZTcUM2S0tqQUhPSzJ5ZCt0dzREaWtMSzdRbzRwNTZNREREc1NKZDZqRlVQMUFoM1FQdzdrCnR6SnozOEhkcjhUNUJodDZiMnM2eXI5OGx5RWpvMjErQ0JXcmUrV3lTZDVYSW1tT012R2lVZDlOanM0L2htZHQKUE56K2ZCRUNnWUVBNWY3OXVrTHlUN2Q5ejBHay9iYlVkUk9iTUNnWi83RzV3VkJWYlJiY01WOGpkeXhMREQwUAp2clMxRkRnYk4yQTA0M1VpU3JaeE8zakp6enNLcTBGRGlkWDMwZkdFMlRwNkpYZ21jUnFPWHJtT1FvT1VPTnJHClFGWURvZVZwQjUwRjdpOWgxWW1JN1RlaGFDVlVSUmtydjA5L1FnZkZtV3VGcnlCdHNTK3cvbjBDZ1lFQTE0bzQKcklLc2NPVHU2clAzNlRrNndpNW1uWjFZQUUreXEyVlltRm5rTmMrNUNyVC9scUdBR0NRdXptQ0QrSHliQWxqZQprTkJab3VLcXYrQkxERG9CalFWZ0k2M3hTTExQalVZa0FjUVNZVDhNTTF6UXpzRXY3WFFtTzU0c0x5UzJMcFZxCmhFSVhMSkVCTkZmMVd4aERIRnFDYVdUWGpvVnZzYzc0RFJjZkNsVUNnWUVBbCtYUGh2dDk4eDRaamc4cHU1TEwKUUVOaG8rMW9ObElYZjAvaUMza2tsY3Jpcm10bmFUN09ya0hFc2dUWUhMdUNVcExpd2ZzNlQyL1h3UENhZkQ1UApMN0pMeUxFODd3Yks4d0ltU1Y2amxuWHdPWWVURmZXUEo2Qm5KNzVPbm9PYkRoTG5CMU9kUmlZT2lLeld1Z2dFCnQ0WDJZeEtrODAxcTdoMTV0S0x0dnpVQ2dZQVJiWENscWk4dE5hV0h2cU4xN1JXdUs3aEtXRFdNV09WV2JHeGMKYlRCQmxaa2RuNExtK0FuMmFiNkxHMHl3WThyWXhyekFNc2g4bmgwMlJIbHM5S2U1Y2t6U3RiYkRyUW1SSDdHNwpudEhwb1FKb2lNR3RaZnR0Rks0ZXRleFdwMzQvaC85RDBHQTFUMGdzcGt3RllKSFVraERuV3FyL01CVFc2S2d2CnpzWEl2UUtCZ0hvV0hwRWI0RTRlUGxrWEcxWVVpTjdScWtHQWcxWTNIMmF5OUFMZ0Qvdi9CbldScXQ2WXovckwKZlY1R2oxbXdQRldyZDEzOG8xYm5GZXgyNlFGbkZoM1hXU0Z5RWNlclFQMVZJZ1B0bFJzTmtsUnFURW4vSlhlTwplb1AwVDlCSTJ0aHpydFZEUE1Vd2JkSmZ2cWVuaEZ3VGJsZXhESTZpRS8zVStFNENKbXF4Ci0tLS0tRU5EIFJTQSBQUklWQVRFIEtFWS0tLS0tCg=="
domain_root_crt = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUY2ekNDQTlPZ0F3SUJBZ0lVTm1GWk5sTHlEMVIwMzd3SUhxSXB2ZkV5SnY4d0RRWUpLb1pJaHZjTkFRRUwKQlFBd2dZUXhDekFKQmdOVkJBWVRBa0ZhTVFzd0NRWURWUVFJREFKQldqRU5NQXNHQTFVRUJ3d0VRbUZyZFRFVQpNQklHQTFVRUNnd0xTRzl6ZEdGeWRDQk1URU14Q3pBSkJnTlZCQXNNQWtsVU1STXdFUVlEVlFRRERBcG9iM04wCllYSjBMbUY2TVNFd0h3WUpLb1pJaHZjTkFRa0JGaEpoTG10aGJtRnVRR2h2YzNSaGNuUXVZWG93SGhjTk1qUXgKTURFME1UQXdNakUyV2hjTk16UXhNREV5TVRBd01qRTJXakNCaERFTE1Ba0dBMVVFQmhNQ1FWb3hDekFKQmdOVgpCQWdNQWtGYU1RMHdDd1lEVlFRSERBUkNZV3QxTVJRd0VnWURWUVFLREF0SWIzTjBZWEowSUV4TVF6RUxNQWtHCkExVUVDd3dDU1ZReEV6QVJCZ05WQkFNTUNtaHZjM1JoY25RdVlYb3hJVEFmQmdrcWhraUc5dzBCQ1FFV0VtRXUKYTJGdVlXNUFhRzl6ZEdGeWRDNWhlakNDQWlJd0RRWUpLb1pJaHZjTkFRRUJCUUFEZ2dJUEFEQ0NBZ29DZ2dJQgpBTHdsSFRiMEVtNGpqM2F6b1BmSWp4NXZWbmN3MDlzQ0wzVzdpQ3B4cDJSZ1dOL2pRRG0yVWNsZ2diL1FiMjZtCk91bjk0dEI2WW1JWU5YTHpPaXJXcDAwcG9vbU1LckJWMDQzMjZlSkhRU0lpM0tXQ0tlSCtXZGlIWFhiUzJ2elcKWjZDUmY3RGZuTHZGSlVsV05YTFlWazVDNDRBSm9FWUUzbnJRTytzdHM4SE5JYlY1WUZ6cXZJRk1pa29NR1g4cApyeXozOXIvd0Q1a3FhSVVPdk9iZVIrOG9hY2lvVlJzSkZWekloRDFtdy91VmtOUDBxSVdMTkNtZkx5elp3SlNsCmpNQ2RRcStPUnl1MlloN04yNkY4R05xVUZROVhYaHo5eExCR1g4Qzh4VncrME5VeU5BNXBJMzdiMElYRC8zT2cKTEsrS0pXSk1xUVNqREF3L1ZoMDVGbDIwVzVRR1BORWl1UlcvWFdSL25salorYm1lcjlwKzhETUFBTEtzQm5VNApwMUtEV1NKcFpNOU5SRGszamx4MTdsVXFQUm51d3VzZFMxY09ybjZFWmwxaWVpbDIzVE9jMk91cUlDRFpyaEhWCnppZ1NYZ25nZlpSd0ZCSUpleDVBZ0pMcjZ5OWNqVjdZRksxaDJQSWpvVzJZWFkxYUxFL0dlRURqamg4Y2ZldGsKMHVJbkFIQ3o2M0o1dmpBV3BVUk8yeWpsbXdvMzBDVkdwTmh1cElJS2ZTZmM4bVNtcGtFOHhyVmtvVU50YVFSTApnKzUrSzB5MnZGanFScE05OXo5dWU4TjZiaDFWYXRzMzBacy9rM2EwZzh1Nm94aHd5Vzhhc3pVdUIzNzRPcnE1Cll5WDhwSE1lTGZSTjE3UnJRS3Ryc2FwVUFOSzdJNTloVWVheTl2d0JOZ2kzQWdNQkFBR2pVekJSTUIwR0ExVWQKRGdRV0JCVGtDd0tNNldTNlFpSzJHWVR0dWtEYUZqME5iVEFmQmdOVkhTTUVHREFXZ0JUa0N3S002V1M2UWlLMgpHWVR0dWtEYUZqME5iVEFQQmdOVkhSTUJBZjhFQlRBREFRSC9NQTBHQ1NxR1NJYjNEUUVCQ3dVQUE0SUNBUUFHCk1FUld2cVZyODJhQjY3cDFtR2xFSnBLZDIrSTVmemh1MHU3S1dscjJJWWwvSGdBb0l5VHM3eG43Nm9uRVJiU20KREMzbG51bWJkRVJYeXk0bFgrem5TMWRRZjFEclhYU1dCZXc2ck9nUmZRcFdNdlZVWitrRHZjd0I2WXdjUVovTQpVb3Q5TURadGswSWxlQmdNNnFqTU1NZVhydjdVUElTbTAzZFBDckdHcjRmVytwaGFMZDJxdzZUb2UycUc4UU1ZCk56b01aWFVrVHpQR0h4VG9OMnM3eGVoVjhWNGN6NUtqemxtZmdnRmJCbGQzZ1I5YzRZdm00M1JrSWs1cjI5YUgKR3BoZTJ6ZmFjaU05UjN0RlB4emlzTWVySmhHd2QvM2NseVFjRXhDcGd3NkVpUFJqY1MyUFNnS09DbTV2b3RWWQpqUXZIMGNDZFY1RDdJbmJ3VWdxSHRNOUtnc2xjT1RoOHpjYU03alNXeDUrNk1YUjlwS29rY2h5QURLdU1Ed2dTCmpkdHVlazFXWlJwamhtNDZSakYvV2Vuamg5d1RRQlJWTGp1N3pWNGRsOGo5UVF5dzNwais1R1lVNW52Mnd5MjEKU0N1QjNtMERBU3VjcE1rU2QrYlUwNFBKM2JUMitUbk9NZTV2QUU0U20rbUs4SGJsNUdQdnpHZmFvSjcyVDl4TQppNDdvdk51WlhmSDk4VDY5UmxJUWFWbUFmeUo4cE8rUHgxMmJqZWtCUEp2V2w3WUxWdXg4MWE2K3BJSjRxNjY4CitGaXJZakVxODcxRjNQU2FiK1ZrVFFDN0NzclNMOG5JekhseDBKZmxpVlpCRU00NjR6b1Z1d2lqZFBxUmQwK08Kc081WmN6cVVZeXNBVXhKSTVtbGlHdFhsQkE0anEvenc0S2tLNU83clVBPT0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo="
domain_root_key = "LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpQcm9jLVR5cGU6IDQsRU5DUllQVEVECkRFSy1JbmZvOiBERVMtRURFMy1DQkMsMzQ3RjNFRjc5MjNFRjMxMwoKV3hBeHRhMFd4Mk9VNDc0UHVpeVZ6VUF4UEp3Vmd4S0t6MWEwY1VXaldFVlN6VFpSOHJucW5jZUN2cGtkZEdOYQpOdUI3bWZzUlJsUWhzQTdabDNHRld3MXhqeTJ2RWJSa1dObWpzVTRLNUVxdFBkd0FvdTd3RnJFZU14bmhlRHdkCk5FSTVoSzVTYUsrVVNiTEcxcTM1WWFIaXBxNGJCYkVkNVVYU1BSZkx6RFpkTkJDZnpBeS9JeWhHc1hGa2ZWUVIKUkVkaDFpdllhaU5rNUQyNVRlQWx2c2JERWVNS2xvUVYyWWt1UE0wUEtWRFFndFZSTVR6eEdOR0dIcXc3bWdDYgpMWFRBd205d01GM1p5emxjV2hOdm12Wkt5OG5TRVR0SzNCSG5kNEEvRjVEWWM0aElIcjBJVWpEVnZzajZzeE9QClJHUmVUaUxPY3RSaGpXWjBWRTZJeGxvS1R3andobldtMjZ0NkVRWE5HZ3ZXOCttQWtnbE1jVEdicnFHQjZSNm8KNjBkMjNPRVVibVdXR2Y1SU5uck9kRHZ0b3phRVRydHBVcExMdGNqcE4xRjhVK1RIR0drcXVxRHRwZzFHZjRkdgpCdG1vUllhTXJ2SXFTenRKTlJteVZtRFVEdUx2UTR5amp4bzg1VTI0Rm1hSTBLZW1GMWJHb0JrOGVrc0JGKzJ1CmJnRzFlNWVrR1lJcm1Pdm1CeTk2VkJXN0ZzcUtoMEV3Y09DZlNIM1BZY2ZHOU4yVThOQkNtZ0c2R281NEZiQmkKbDFlay9yWEFFYmF1VGhWRW5LZ2NkRnU4anZZaWpRSmcva1U2bjg2M0JVcFFzQ2hDNVdESW8rV3RiOEEybURsOAo5REFEQVFpV3drZFgxV1Z1Q1RBQlFaUkdpMks0aDNqQlRvQjBjZkdlYXlseXlCZi9rc2RkYWU0Y0I1UUFJSmZJCmpFT25sMFJVQjR5dkdDbWdIQVR5N1MrV0thajlNdEROcXJ0SjNndDZZbHljOVAwVUZSdEhCWDZ3VXRIZUhZVUUKcUczUmRxbTJ2Z1BRWW8vWnU3MVJmUTFzQ01jQVZVZlRncXVIK2RyOWE0alJGNmd1Mk9najVyZkVaK3lYV0U3OQp3T1R1bklyRDdJNVJZaVhPT1AzNm55TFdSZkczMytrQzk3ME92cEJmaitVSURyZ2N2UW92Vjk0RWt6WUtwM0RmCk5oZ3JEbkZ4Y0tMOHI5VzZuOWZ1YnlhNzZha0hkemZKL0JuQmNwYlBXZFExdjllcjhaK0RqdnRNNWJLT1lXVlcKcmQ0UTVjeUYyVU9neERSZ1NyL1BGdjVNZjVrNWZkR3U2enpwTUJqUVJON3ZsbXBVTGNpTkozL1A4Z1BmMVk1WQptUjhVM2RhaU1hTVlGTVkxVDFaK0VTdmNKODlKcVlnd3hnMk54RVczeEpmb0tHczZHbHNEM0F6alAyY05mUjFCCmFBZFM4U2dXaHBtSHJtejYxY2dTc2doRjVrVGNVbU1ZdjJkcmdGaStFMjArNnJDY2llWE5uRENULzhBcW1FeWQKSE9GU0p0aGIyZWtyeDJ2UU41VzM4elZQRGF1WG1aQTRXM2ZHcnM1ekZLVHVQU0JTOVNhRnJpbTVYNW9naVZlRwpNbVUzU1NLakN4MzZkSE85MWU5MndadSszVk9RR0oyV2RjMXdnRFpIZ3VtVHdKYi9rem50ZjVvWVRySVBKOE9hCmIxL2JvS3JGYmkyREJabTl6OE1KdVZzNlhpNDNsUUtwTzZrOFFkMGhpLzk4K043R21PYXo0UFlnbWUwbHVtRG4KYlFrUmttcFhoYVNLWGVVaUFSLy94bG0wQ01sckQzeWV2RGxhbW5yZU0zUFZIazBDbzVvMkJjYXBXZG9qWkJyNgphVHJyQVozMUpxWTJuQTBNbGt5SVlMdXgrTlZHckxYTU5hU0NUWldnM2l4VUhUeEllUkhsY0t6V3FhV1ZCQ2tHCi9qdkdZcnkwVFUzSmxod0hsYjQvYXpBcnN1N1ZJZGRGQVVWNFgyQm53UXkzNjRYbmtmQnIzU2RuVGRMOFFlK3QKU1dGeXNVZGFtalJpRWtwRTJJWFdnSkpOUTQrMkZPaW93b0h0cjJxVVVXSTVYdmlaZG9UaDVxbFN6WXNTckVJeAoveVRkcTRqOGtldzBVYWJTdjBzeDJzK3A0NmNzN0RtM0pQMkZhc1Q5MmhZNGx2Y1dxM3lNdjlLVXpoYnhuTm5ZCk94SlFnZ3JNWFUreVhjV3dUKzZxN1NzaEg1ZTNuc1pxMThlbFo4Y01xR1MyaUphVUxLUGl3bisxMmxhdS9pZzQKUEh6YkM5RE5CWUM3azRYU0Vob1MvV3kvNTRSak1NelNLZExOTXdUTVZPOGxCa1VBWmtHekpXempabUZ4VDVJOQpVbTRhbVhFb3F5bG1zMEdZRVNDa0lUT2JpU1B3LzQzNFA5VVNKeEdTNlVBWFU3aUxwUG92cmJERW9rS0lCY2hZCmNpZ01RMWJZeHdibjlUdjFPUENQVnJDNHNJTnBwUk9wS1MzNlFzTmxXVGVNMWpYR2p1bGxZaUNHODFDanhWQlAKZ2ZBWTI0Uk1EM1diVWdvNG52VDhDS3BmenRhSzVMa2xRMUhoU0dxR2U4VHBDZmFSeU9WdCtxRVRsQUtjZmh1SQpnT3duNW1MOUNIZERSY1VLZG5rOTR5SnZUMlVGaFk4OWlKMUxVNWtnTVlTVkxmUnEyZnhOdHdUMGJITGVyYjBtCmJlMzR3RlBsbVcwMGVTOEJEOGlneTN3bitHMStFUXZza0tqSk5xK2M1YlZLMW81T0YxT21SM2ZwaFhMcllwNnUKbHlkSk5YOWN4KzR0MHVsOGtSTUFzKzRORzlOaWFGbDRjcWloc0Q0Ni8xQnpUeExNdUhsOUU1R2h6Z1RCZzFEYwpzaE5UUnJ1TE5VVmlLSWp4eTRMeEN5NDJCTEtCa0hwWkZjR0cvdFE0d0VWUjMvV2lacEw1aG41cWF3bms5Ymo3CkVIOGxQWFFqZzBkMXVOU2JwcVBZT3ViY0dxcHhib3dLalBHMm04MG04SmpyV1NlOHNYeWJXakFodHg2TnFZSDgKOHM2TnpQdE0vdXVoRnJaQU41eVdLTE1FVGlUeWVFU3E4dEdNR3lGd0toN1VVT2ppU1pvUTdUcTlUS2N3aXREVQpsRE12SlMxL016UTJHQ2FpV3IvanNvU0hEdXY5Q0g5Y0RXcGhEc0FnSGRyZHRFWVhQTUxhNmtsM0hrMld4ZGFXClM5RmQxSlNMRFpPOW9YVlpFTGpjS0xhV3pYK2cwQ1JlNG5teUZDSEZOZTAvM2xWd2ZkeWRCUmlCS0VONzRTODMKVmFsMmtrMFludExCZ3BwbURNV1gxRm9OcXlvQ1d1eXVmd3BqcWRLRm9EYm9oeTgxa2dWMVd3bzI0NUxsK3BGagpmbHh2SnR6YVBOV09yRlpHY0RmaEx0aFhxZERxYjdDazc3NWJoYjIrNk9hRklzeW1OL3RKRTlxVlR6N3JKV2EvCnpWOG9CKzdhRkJwMkoyZUlIUUVrR1pMbzdNR1hVd25lbmxZSk0ralducUV3U1VUVTVMTGhDMEdOdHV5Qk5KaGgKNmxDZ0UzYlFnNnRjcmJjSVJoZkN2K2FnNmRiOEV2emIzZ1MvZ2NjYkI4WVduTVYwcmlNYWF6WlV0Y2UzRmd4ZApYR0IweWZid09xZmxCcWl5Y3dBcWcyWTBHZ3laN1N4dWpsdEhmT1pJRnM2eHlHVnVFbk93TGlLZXBONGFKYy9hCmR1dDdLWUsrOW05TjNqa0FnTEZ6TkRNVWpZQWt0TUVGK3lBaHBORndiK3VHNW1IM1o5UzVwRjJSeW5IY253d3EKN00wQVYwMysvc1dJVUVqSWJPVWNaSmVUYlJKdnlleUxLWE9pZmVFZEJ1Wm50TXRPQnozRW1uZk52Q2NvN1F5QgpaVmFmSmc1WWQ2ZWVXVnFOeXpLTGQ5MmpTV2U3dllRNHZabTRkSEVaYWZDNXl2NCs2cVZMcnlSOXdOMFdUSmdXCnNmUXFSNGFqQVkxbldUM1pGSWtMLzFSWkFLS3NEb0ZaamRxYUNWSVR6bXgyQ3FzcVlaMDdHS09hb3VjWTRidVUKTENTcUtuVVQyOVVPWkJtUnJqY3U3dVBrc3lCdEVaREI5ZlNLNldDSjZDYyt0K0QwZk4zY3hzTDArZjltakRVUgotLS0tLUVORCBSU0EgUFJJVkFURSBLRVktLS0tLQo="

#===========================#
slack_channel_name         = "hostart-notifications"
slack_network_channel_name = "network-notifications"
slack_webhook_url          = "https://hooks.slack.com/services/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"
slack_network_webhook_url  = "https://hooks.slack.com/services/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"
#===========================#


/*
Initialization:

export GITLAB_ACCESS_TOKEN=<ACCESS_TOKEN>
terraform init \
    -backend-config="address=https://<gitlab_url>/api/v4/projects/<project_id>/terraform/state/tfstate" \
    -backend-config="lock_address=https://<gitlab_url>/api/v4/projects/<project_id>/terraform/state/tfstate/lock" \
    -backend-config="unlock_address=https://<gitlab_url>/api/v4/projects/<project_id>/terraform/state/tfstate/lock" \
    -backend-config="username=<gitlab_user>" \
    -backend-config="password=$GITLAB_ACCESS_TOKEN" \
    -backend-config="lock_method=POST" \
    -backend-config="unlock_method=DELETE" \
    -backend-config="retry_wait_min=5"


*/