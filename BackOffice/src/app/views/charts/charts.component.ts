import { Component, OnInit, ViewChild } from '@angular/core';
import { ReclamationService } from 'src/app/services/reclamation.service'
import { MatSort, Sort } from '@angular/material/sort';
import { MatTableDataSource } from '@angular/material/table';
import { LiveAnnouncer } from '@angular/cdk/a11y';

@Component({
  selector: 'app-charts',
  templateUrl: './charts.component.html',
  styleUrls: ['./charts.component.scss']
})
export class ChartsComponent implements OnInit  {

  reclamationList:any[]=[];
  search :string;

  constructor(private reclamationService: ReclamationService, private _liveAnnouncer: LiveAnnouncer) { }

  getAllReclamation() {
    this.reclamationService.getAllVoiture().subscribe(res=> {
      for(const prop in res) {
        for(const e in res[prop]){
          this.reclamationList.push(res[prop][e]);
        }

    }
    console.log(this.reclamationList);

    }
    )
  }


  ngOnInit() {
    this.getAllReclamation();
   }


}
