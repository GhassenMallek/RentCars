import { TestBed } from '@angular/core/testing';

import { MedecinesService } from './medecines.service';

describe('MedecinesService', () => {
  let service: MedecinesService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(MedecinesService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
