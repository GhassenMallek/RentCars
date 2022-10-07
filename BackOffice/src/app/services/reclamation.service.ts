import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';

@Injectable({
  providedIn: 'root'
})
export class ReclamationService {
  readonly API_URL = 'http://localhost:3000/user';
  readonly API_URL_car = 'http://localhost:3000/car';

  constructor(private httpClient: HttpClient) { }

  getAllReclamation(){
    return this.httpClient.get(`${this.API_URL}/`)
  }
  getAllVoiture(){
    return this.httpClient.get(`${this.API_URL_car}/`)
  }

}
