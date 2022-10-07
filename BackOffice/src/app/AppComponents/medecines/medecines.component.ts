import { Component, OnInit } from '@angular/core';
import {MedecinesService} from 'src/app/services/medecines.service'

@Component({
  selector: 'app-medecines',
  templateUrl: './medecines.component.html',
  styleUrls: ['./medecines.component.scss']
})
export class MedecinesComponent implements OnInit {
  medecinesList:any[]=[];
  search :string;
 
  constructor(private MeddecinesService: MedecinesService) { }

  getAllMedecines() {
    this.MeddecinesService.getAllMedecinesn().subscribe(res=> {
      for(const prop in res) {
        for(const e in res[prop]){
          this.medecinesList.push(res[prop][e]);        
        }
      
    }
    console.log(this.medecinesList);
    
    }
    )
  }
  
  ngOnInit() {
    this.getAllMedecines();
   }
 
}

